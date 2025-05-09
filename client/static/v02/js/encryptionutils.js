// Many thanks to this gist:
//  https://gist.github.com/chrisveness/43bcda93af9f646d083fad678071b90a
// and this web site:
//  https://webbjocke.com/javascript-web-encryption-and-hashing-with-the-crypto-api/

const generateRandomByteArray = (size) => {
    return crypto.getRandomValues(new Uint8Array(size));
}

const byteArrayToHex = (arr) => {
    return Array.from(arr).map(b => ('00' + b.toString(16)).slice(-2)).join('');
}

const byteToHex = (byte) => {
    if (byte < 16) {
        return '0' + byte.toString(16);
    }
    return byte.toString(16);
}

const hex = (hashArray) => {
    const hashHex = hashArray.map(byteToHex).join('');
    return hashHex;
}

const sha256HashArray = async (message) => {
    // https://stackoverflow.com/questions/18338890/are-there-any-sha-256-javascript-implementations-that-are-generally-considered-t
    // encode as UTF-8
    const msgBuffer = new TextEncoder('utf-8').encode(message);
    // hash the message
    const hashBuffer = await crypto.subtle.digest('SHA-256', msgBuffer);
    // convert ArrayBuffer to Array
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray;
}


const sha256 = async (message) => {
    return hex(await sha256HashArray(message));
}

/**
 * Generate new key.
 *
 * @return {string}
 */
const generateKey = async () => {
    const alg = { name: 'AES-GCM', length: 256 };
    const extractable = true;
    const keyUsages = ['encrypt', 'decrypt'];
    const key = await crypto.subtle.generateKey(alg, extractable, keyUsages)
    const jwk = await crypto.subtle.exportKey('jwk', key);
    return jwk.k;
}

/**
 * Import a string key.
 *
 * @param {string} k
 */
const importKey = async (k) => {
    const jwk = { alg: 'A256GCM', k, ext: true, kty: 'oct', key_ops: ['encrypt', 'decrypt'] };
    return crypto.subtle.importKey('jwk', jwk, 'AES-GCM', true, ['encrypt', 'decrypt']);
}

/**
 * Encrypt an object.
 *
 * @param {object} obj - An object to serialize and encrypt.
 * @param {string} key - Key
 *
 * @return {string}
 */
const encryptJson = async (obj, keyStr) => {
    const key = await importKey(keyStr);
    const str = JSON.stringify(obj);

    const iv = generateRandomByteArray(12);

    const alg = { name: 'AES-GCM', iv: iv };

    const ptUint8 = new TextEncoder().encode(str);
    const ctBuffer = await crypto.subtle.encrypt(alg, key, ptUint8);

    const ctArray = Array.from(new Uint8Array(ctBuffer));
    const ctStr = ctArray.map(byte => String.fromCharCode(byte)).join('');
    const ctBase64 = btoa(ctStr);

    const ivHex = byteArrayToHex(iv);

    return { iv: ivHex, encryptedData: ctBase64 };
}

/**
 * Decrypt an object.
 *
 * @param {string} str - Encrypted serialized JSON object.
 * @param {string} key - Key
 *
 * @return {object}
 */
const decryptJson = async (encryptedData, ivHex, keyStr) => {
    const iv = ivHex.match(/.{2}/g).map(byte => parseInt(byte, 16));
    const alg = { name: 'AES-GCM', iv: new Uint8Array(iv) };

    const key = await importKey(keyStr);

    const ctStr = atob(encryptedData);
    const ctUint8 = new Uint8Array(Array.from(ctStr).map(ch => ch.charCodeAt(0)));

    const plainBuffer = await crypto.subtle.decrypt(alg, key, ctUint8);
    const plaintext = new TextDecoder().decode(plainBuffer);

    return JSON.parse(plaintext);
}

const post = (url, data) => {
    return new Promise((fullfil, reject) => {
        const req = new XMLHttpRequest();
        req.onreadystatechange = () => {
            if (req.readyState == 4) {
                if (req.status == 200) {
                    const json = JSON.parse(req.responseText);
                    fullfil(json);
                } else {
                    reject(req);
                }
            }
        }
        req.open("POST", url);
        req.setRequestHeader("Content-Type", "application/json");
        req.send(JSON.stringify(data));
    });
}

const get = (url) => {
    return new Promise((fullfil, reject) => {
        const req = new XMLHttpRequest();
        req.onreadystatechange = () => {
            if (req.readyState == 4) {
                if (req.status == 200) {
                    const json = JSON.parse(req.responseText);
                    fullfil(json);
                } else {
                    reject(req);
                }
            }
        }
        req.open("GET", url);
        req.send();
    });
}

/**
 * Prove/sign project key.
 *
 * @param {string} key
 * @param {string} hashPrefix
 * @param {number} rounds - Number of rounds of hashing, i.e. length of resulting nonces array.
 * @param {function} [port] - Port to send (intermediate) results to.
 * @param {string[]} [knownNonces] - Pre-computed nonces
 *
 * @returns {{ cancel: function, promise: Promise<String[]> }}
 */
const prove = (key, hashPrefix, rounds, port, knownNonces = []) => {

    let cancelled = false;

    function hexStart(hashArray, len) {
        const hashHex = hashArray.slice(0, len).map(byteToHex).join('');
        return hashHex;
    }

    const chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

    const charToIndex = {};

    const nextChar = chars.reduce((acc, cur, index, arr) => {
        acc[cur] = arr[index + 1];
        charToIndex[cur] = index;
        return acc;
    }, {});

    let strArr = [];

    const next = () => {
        for (let i = 0; i < strArr.length; i++) {
            const c = strArr[i];
            const next = nextChar[c];
            if (next) {
                strArr[i] = next;
                for (let j = 0; j < i; j++) {
                    strArr[j] = chars[0];
                }
                return;
            }
        }
        // No next
        for (let i = 0; i < strArr.length; i++) {
            strArr[i] = chars[0];
        }
        strArr.push(chars[0]);
    };

    const check = hash => hexStart(hash).startsWith(hashPrefix)

    let base = key + 'czoodle';

    const run = async () => {

        const start = Date.now();

        for (nonce of knownNonces) {
            base = await sha256(base + nonce);
        }
        const results = knownNonces.slice();

        port?.send(results);

        for (let round = results.length; round < rounds; round++) {
            strAttr = [];
            for (let i = 0; ; i++) {
                if (cancelled) {
                    return;
                }
                const nonce = strArr.join('');
                const val = base + nonce;
                const sha = await sha256HashArray(val);
                await new Promise(resolve => setTimeout(resolve, 1));
                if (check(sha)) {
                    base = hex(sha);
                    results.push(nonce);
                    port?.send(results);
                    break;
                }
                next();
            }
        }

        return results;
    };

    const promise = run();

    return {
        cancel: () => { cancelled = true; },
        promise,
    };
}

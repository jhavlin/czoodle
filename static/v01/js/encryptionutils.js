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

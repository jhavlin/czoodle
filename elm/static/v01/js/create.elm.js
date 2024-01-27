(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File === 'function' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[94m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.ab.H === region.al.H)
	{
		return 'on line ' + region.ab.H;
	}
	return 'on lines ' + region.ab.H + ' through ' + region.al.H;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return word
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.bL,
		impl.cT,
		impl.cK,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	result = init(result.a);
	var model = result.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		result = A2(update, msg, model);
		stepper(model = result.a, viewMetadata);
		_Platform_dispatchEffects(managers, result.b, subscriptions(model));
	}

	_Platform_dispatchEffects(managers, result.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				p: bag.n,
				q: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.q)
		{
			x = temp.p(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		r: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		r: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**/
	var node = args['node'];
	//*/
	/**_UNUSED/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS


function _VirtualDom_noScript(tag)
{
	return tag == 'script' ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return /^(on|formAction$)/i.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,'')) ? '' : value;
}

function _VirtualDom_noJavaScriptUri_UNUSED(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,''))
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value) ? '' : value;
}

function _VirtualDom_noJavaScriptOrHtmlUri_UNUSED(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value)
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		s: func(record.s),
		ac: record.ac,
		_: record._
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.s;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.ac;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value._) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.bL,
		impl.cT,
		impl.cK,
		function(sendToApp, initialModel) {
			var view = impl.cU;
			/**/
			var domNode = args['node'];
			//*/
			/**_UNUSED/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.bL,
		impl.cT,
		impl.cK,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.aa && impl.aa(sendToApp)
			var view = impl.cU;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.a9);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.S) && (_VirtualDom_doc.title = title = doc.S);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.b5;
	var onUrlRequest = impl.b6;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		aa: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.aN === next.aN
							&& curr.as === next.as
							&& curr.aK.a === next.aK.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		bL: function(flags)
		{
			return A3(impl.bL, flags, _Browser_getUrl(), key);
		},
		cU: impl.cU,
		cT: impl.cT,
		cK: impl.cK
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { aq: 'hidden', bc: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { aq: 'mozHidden', bc: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { aq: 'msHidden', bc: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { aq: 'webkitHidden', bc: 'webkitvisibilitychange' }
		: { aq: 'hidden', bc: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		aT: _Browser_getScene(),
		cV: {
			T: _Browser_window.pageXOffset,
			c_: _Browser_window.pageYOffset,
			F: _Browser_doc.documentElement.clientWidth,
			A: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		F: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		A: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			aT: {
				F: node.scrollWidth,
				A: node.scrollHeight
			},
			cV: {
				T: node.scrollLeft,
				c_: node.scrollTop,
				F: node.clientWidth,
				A: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			aT: _Browser_getScene(),
			cV: {
				T: x,
				c_: y,
				F: _Browser_doc.documentElement.clientWidth,
				A: _Browser_doc.documentElement.clientHeight
			},
			bw: {
				T: x + rect.left,
				c_: y + rect.top,
				F: rect.width,
				A: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$GT = 2;
var $elm$core$Basics$LT = 0;
var $elm$core$List$cons = _List_cons;
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 1) {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.b) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.d),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.d);
		} else {
			var treeLen = builder.b * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.e) : builder.e;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.b);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.d) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.d);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{e: nodeList, b: (len / $elm$core$Array$branchFactor) | 0, d: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 1, a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = $elm$core$Basics$identity;
var $elm$url$Url$Http = 0;
var $elm$url$Url$Https = 1;
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {an: fragment, as: host, aD: path, aK: port_, aN: protocol, aO: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 1) {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		0,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		1,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = $elm$core$Basics$identity;
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return 0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0;
		return A2($elm$core$Task$map, tagger, task);
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			A2($elm$core$Task$map, toMessage, task));
	});
var $elm$browser$Browser$element = _Browser_element;
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $author$project$SDate$SDate$SDay = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (!maybeValue.$) {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Array$fromListHelp = F3(
	function (list, nodeList, nodeListSize) {
		fromListHelp:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, list);
			var jsArray = _v0.a;
			var remainingItems = _v0.b;
			if (_Utils_cmp(
				$elm$core$Elm$JsArray$length(jsArray),
				$elm$core$Array$branchFactor) < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					true,
					{e: nodeList, b: nodeListSize, d: jsArray});
			} else {
				var $temp$list = remainingItems,
					$temp$nodeList = A2(
					$elm$core$List$cons,
					$elm$core$Array$Leaf(jsArray),
					nodeList),
					$temp$nodeListSize = nodeListSize + 1;
				list = $temp$list;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue fromListHelp;
			}
		}
	});
var $elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return $elm$core$Array$empty;
	} else {
		return A3($elm$core$Array$fromListHelp, list, _List_Nil, 0);
	}
};
var $author$project$SDate$SDate$daysInMonthsInLeapYear = $elm$core$Array$fromList(
	_List_fromArray(
		[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]));
var $author$project$SDate$SDate$daysInMonthsInStandardYear = $elm$core$Array$fromList(
	_List_fromArray(
		[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]));
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$SDate$SDate$isLeapYear = function (year) {
	return (!(year % 4)) && ((!(!(year % 100))) || (!(year % 400)));
};
var $author$project$SDate$SDate$daysInMonthsInYear = function (year) {
	return $author$project$SDate$SDate$isLeapYear(year) ? $author$project$SDate$SDate$daysInMonthsInLeapYear : $author$project$SDate$SDate$daysInMonthsInStandardYear;
};
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$core$Array$bitMask = 4294967295 >>> (32 - $elm$core$Array$shiftStep);
var $elm$core$Basics$ge = _Utils_ge;
var $elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var $elm$core$Array$getHelp = F3(
	function (shift, index, tree) {
		getHelp:
		while (true) {
			var pos = $elm$core$Array$bitMask & (index >>> shift);
			var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!_v0.$) {
				var subTree = _v0.a;
				var $temp$shift = shift - $elm$core$Array$shiftStep,
					$temp$index = index,
					$temp$tree = subTree;
				shift = $temp$shift;
				index = $temp$index;
				tree = $temp$tree;
				continue getHelp;
			} else {
				var values = _v0.a;
				return A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, values);
			}
		}
	});
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var $elm$core$Array$get = F2(
	function (index, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? $elm$core$Maybe$Nothing : ((_Utils_cmp(
			index,
			$elm$core$Array$tailIndex(len)) > -1) ? $elm$core$Maybe$Just(
			A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, tail)) : $elm$core$Maybe$Just(
			A3($elm$core$Array$getHelp, startShift, index, tree)));
	});
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$SDate$SDate$daysInMonth = function (_v0) {
	var year = _v0.a;
	var month = _v0.b;
	var res = A2(
		$elm$core$Array$get,
		month - 1,
		$author$project$SDate$SDate$daysInMonthsInYear(year));
	return A2($elm$core$Maybe$withDefault, 0, res);
};
var $author$project$SDate$SDate$SMonth = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$SDate$SDate$monthInYear = F2(
	function (year, month) {
		return ((month < 1) || (month > 12)) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
			A2($author$project$SDate$SDate$SMonth, year, month));
	});
var $author$project$SDate$SDate$SYear = $elm$core$Basics$identity;
var $author$project$SDate$SDate$minYear = 1900;
var $author$project$SDate$SDate$yearFromInt = function (year) {
	return (_Utils_cmp(year, $author$project$SDate$SDate$minYear) > -1) ? $elm$core$Maybe$Just(year) : $elm$core$Maybe$Nothing;
};
var $author$project$SDate$SDate$monthFromTuple = function (_v0) {
	var year = _v0.a;
	var month = _v0.b;
	var yearMaybe = $author$project$SDate$SDate$yearFromInt(year);
	return A2(
		$elm$core$Maybe$andThen,
		function (sYear) {
			return A2($author$project$SDate$SDate$monthInYear, sYear, month);
		},
		yearMaybe);
};
var $author$project$SDate$SDate$dayFromTuple = function (_v0) {
	var year = _v0.a;
	var month = _v0.b;
	var day = _v0.c;
	var monthMaybe = $author$project$SDate$SDate$monthFromTuple(
		_Utils_Tuple2(year, month));
	var makeDay = function (m) {
		return ((day > 0) && (_Utils_cmp(
			day,
			$author$project$SDate$SDate$daysInMonth(m)) < 1)) ? $elm$core$Maybe$Just(
			A2($author$project$SDate$SDate$SDay, m, day)) : $elm$core$Maybe$Nothing;
	};
	return A2($elm$core$Maybe$andThen, makeDay, monthMaybe);
};
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$map3 = _Json_map3;
var $author$project$Common$CommonDecoders$decodeDay = A4(
	$elm$json$Json$Decode$map3,
	F3(
		function (y, m, d) {
			return $author$project$SDate$SDate$dayFromTuple(
				_Utils_Tuple3(y, m, d));
		}),
	A2($elm$json$Json$Decode$field, 'year', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'month', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'day', $elm$json$Json$Decode$int));
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $author$project$Translations$TranslationEn$translationEn = {
	bi: 'EN',
	r: {
		bb: 'Cancel',
		bn: _List_fromArray(
			['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']),
		by: 'Error',
		bT: _List_fromArray(
			['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']),
		aF: 'Description:',
		cl: 'Options:',
		aH: 'Name:',
		aI: 'Date',
		aJ: 'General',
		cs: 'Title:',
		ct: 'e.g. Teambuilding, gift for aunt, or reunion of ballet dancers',
		cv: 'Remove',
		cF: 'Save changes',
		cP: 'Today',
		cS: '(no name)',
		cY: 'Wait, please.'
	},
	n: {
		a2: 'poll',
		a3: 'Add ',
		a4: ' for: ',
		bl: function (n) {
			return 'Create project (' + ($elm$core$String$fromInt(n) + ' polls)');
		},
		bJ: 'A project contains one or more polls of various types.',
		bX: 'New Project',
		cg: 'To decide a\u00A0question about WHEN.',
		ch: 'To decide a\u00A0question about WHAT, WHO, HOW or WHERE.',
		co: 'The link contains a decryption key. If you loose it, you won\'t be able to access your project.',
		cp: 'Only encrypted data are sent to the server. Without decryption key, they are pretty useless. So keep the link in a safe place ;-)',
		cq: 'Congratulations. Your project has been created. Please distribute the link below to the people that should vote.'
	},
	bq: {bJ: 'Only authorized personnel should edit project definition.', bK: 'Consider informing voters about the changes.', cH: 'Scroll down and save or cancel', cL: 'Switch back to voting'},
	bU: 'Controls in English',
	h: {
		a1: 'Add option',
		bu: function (i) {
			return 'Poll ' + ($elm$core$String$fromInt(i) + ': Date');
		},
		bv: function (i) {
			return 'Poll ' + ($elm$core$String$fromInt(i) + ': General');
		},
		bE: ' (hidden)',
		bF: 'Hide',
		b4: 'nothing selected :-(',
		b9: 'Mark available options in the calendar.',
		ca: 'Enter list of available options.',
		cb: 'Overview of options:',
		aG: 'Here you can enter more detailed information about the poll if you want.',
		cm: 'e.g. When will we meet?',
		cn: 'e.g. What gift? or Which pub?',
		cw: 'Remove poll',
		cR: 'Unhide'
	},
	cW: {a5: '+ Add person', a6: 'Add another person to all polls', bg: 'Clear empty rows', bh: 'Remove all rows with no entered name from all polls', br: 'Edit project (Authorized personnel only!)', bs: 'Edit this row. Please remember that changing votes of others without consent is not nice!', bx: 'Enter name!', bH: 'If needed', bP: 'Legend', bQ: 'Loading', bW: '(new person)', bY: 'No', cf: 'Poll', cA: 'Revert changes in this row.', cB: 'Delete', cC: 'Delete this row in this poll', cD: 'Revert', cE: 'To be deleted.', cG: 'Saving', c$: 'Yes'}
};
var $author$project$Translations$Translations$default = $author$project$Translations$TranslationEn$translationEn;
var $author$project$Translations$TranslationCz$translationCz = {
	bi: 'CZ',
	r: {
		bb: 'Zrušit',
		bn: _List_fromArray(
			['Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne']),
		by: 'Chyba',
		bT: _List_fromArray(
			['Leden', 'Únor', 'Březen', 'Duben', 'Květen', 'Červen', 'Červenec', 'Srpen', 'Září', 'Říjen', 'Listopad', 'Prosinec']),
		aF: 'Popis:',
		cl: 'Možnosti:',
		aH: 'Nadpis:',
		aI: 'Datum',
		aJ: 'Obecné',
		cs: 'Název:',
		ct: 'např. Teambuilding, dárek pro tetu, nebo třeba sraz baletek',
		cv: 'Odstranit',
		cF: 'Uložit změny',
		cP: 'Dnes',
		cS: '(bez názvu)',
		cY: 'Čekejte, prosím.'
	},
	n: {
		a2: 'hlasování',
		a3: 'Přidat ',
		a4: ' pro: ',
		bl: function (n) {
			return 'Vytvořit projekt (' + ($elm$core$String$fromInt(n) + ' hlasování)');
		},
		bJ: 'Projekt obsahuje jedno či více hlasování různých typů.',
		bX: 'Nový projekt',
		cg: 'Když se rozhoduje o\u00A0tom KDY.',
		ch: 'Když se rozhoduje o\u00A0tom CO, KDO, KAM nebo KDE.',
		co: 'Odkaz obsahuje dešifrovací klíč. Pokud o něj přijdete, nebudete moci k hlasování přistupovat.',
		cp: 'Na server se posílají pouze zašifrovaná data. Bez dešifrovacího klíče jsou bezcenná. Tak ho neztraťte ;-)',
		cq: 'Hurá. Projekt byl vytvořen. Tento odkaz si zkopírujte a pošlete všem hlasujícím!'
	},
	bq: {bJ: 'Změny by měly provádět pouze oprávněné osoby.', bK: 'Zvažte, jestli byste neměli o změnách uvědomit hlasující.', cH: 'Přejít dolů a uložit nebo zrušit', cL: 'Přepnout zpět na hlasování'},
	bU: 'Ovládání v češtině',
	h: {
		a1: 'Přidat možnost',
		bu: function (i) {
			return 'Hlasování ' + ($elm$core$String$fromInt(i) + ': Datum');
		},
		bv: function (i) {
			return 'Hlasování ' + ($elm$core$String$fromInt(i) + ': Obecné');
		},
		bE: ' (skryté)',
		bF: 'Skrýt',
		b4: 'nic nevybráno :-(',
		b9: 'Označte v kalendáři termíny, o kterých se bude hlasovat.',
		ca: 'Zadejte možnosti, o kterých se bude hlasovat.',
		cb: 'Přehled možností:',
		aG: 'Sem můžete napsat podrobnější informace o hlasování, ale nemusíte.',
		cm: 'např. Kdy se sejdeme?',
		cn: 'např. Co za dárek? nebo Jaká hospoda?',
		cw: 'Odstranit hlasování',
		cR: 'Odkrýt'
	},
	cW: {a5: '+ Přidej člověka', a6: 'Přidej nového hlasujícího do všech hlasování', bg: 'Odeber nevyplněné', bh: 'Odebrat řádky s nevyplněným jménem ze všech hlasování', br: 'Upravit projekt (Nepovolaným osobám vstup zapovězen!)', bs: 'Uprav tento řádek. Pamatujte, prosím, že měnit hlasování ostatních bez dovolení není hezké!', bx: 'Vyplňte jméno!', bH: 'V nouzi', bP: 'Legenda', bQ: 'Nahrávám', bW: '(nový hlasující)', bY: 'Ne', cf: 'Hlasování', cA: 'Zapomeň a zruš úpravy v tomto řádku.', cB: 'Smaž', cC: 'Smaž řádek pouze v tomto hlasování', cD: 'Vrať', cE: 'Ke smazání', cG: 'Ukládám', c$: 'Ano'}
};
var $author$project$Translations$Translations$available = _List_fromArray(
	[$author$project$Translations$TranslationCz$translationCz, $author$project$Translations$TranslationEn$translationEn]);
var $author$project$Common$ListUtils$findFirst = F2(
	function (predicate, list) {
		var fn = F2(
			function (curr, acc) {
				if (acc.$ === 1) {
					return predicate(curr) ? $elm$core$Maybe$Just(curr) : $elm$core$Maybe$Nothing;
				} else {
					return acc;
				}
			});
		return A3($elm$core$List$foldl, fn, $elm$core$Maybe$Nothing, list);
	});
var $author$project$Translations$Translations$get = function (code) {
	return A2(
		$elm$core$Maybe$withDefault,
		$author$project$Translations$Translations$default,
		A2(
			$author$project$Common$ListUtils$findFirst,
			function (i) {
				return _Utils_eq(i.bi, code);
			},
			$author$project$Translations$Translations$available));
};
var $author$project$Translations$TranslationsDecoders$languageArrayToTranslation = function (languages) {
	var isCzechCode = function (code) {
		return (code === 'cs') || A2($elm$core$String$startsWith, 'cs-', code);
	};
	return A2($elm$core$List$any, isCzechCode, languages) ? $author$project$Translations$Translations$get('CZ') : $author$project$Translations$Translations$default;
};
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$Translations$TranslationsDecoders$decodeTranslation = A2(
	$elm$json$Json$Decode$map,
	$author$project$Translations$TranslationsDecoders$languageArrayToTranslation,
	A2(
		$elm$json$Json$Decode$field,
		'languages',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string)));
var $elm$json$Json$Decode$fail = _Json_fail;
var $author$project$Create$CreateDecoders$decodeCreateFlags = function () {
	var topDecoder = A2($elm$json$Json$Decode$field, 'today', $author$project$Common$CommonDecoders$decodeDay);
	var mapper = F3(
		function (sDay, baseUrl, translation) {
			return {a8: baseUrl, cP: sDay, cQ: translation};
		});
	var checker = function (maybeSDay) {
		if (!maybeSDay.$) {
			var sDay = maybeSDay.a;
			return $elm$json$Json$Decode$succeed(sDay);
		} else {
			return $elm$json$Json$Decode$fail('Expected some valid today value');
		}
	};
	var checkingDecoder = A2($elm$json$Json$Decode$andThen, checker, topDecoder);
	return A4(
		$elm$json$Json$Decode$map3,
		mapper,
		checkingDecoder,
		A2($elm$json$Json$Decode$field, 'baseUrl', $elm$json$Json$Decode$string),
		$author$project$Translations$TranslationsDecoders$decodeTranslation);
}();
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $author$project$SDate$SDate$defaultDay = A2(
	$author$project$SDate$SDate$SDay,
	A2($author$project$SDate$SDate$SMonth, 1970, 1),
	1);
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $elm$core$Result$withDefault = F2(
	function (def, result) {
		if (!result.$) {
			var a = result.a;
			return a;
		} else {
			return def;
		}
	});
var $author$project$Create$CreateUpdate$init = function (jsonFlags) {
	var flagsResult = A2($elm$json$Json$Decode$decodeValue, $author$project$Create$CreateDecoders$decodeCreateFlags, jsonFlags);
	var _v0 = A2(
		$elm$core$Result$withDefault,
		{a8: '', cP: $author$project$SDate$SDate$defaultDay, cQ: $author$project$Translations$Translations$default},
		flagsResult);
	var today = _v0.cP;
	var baseUrl = _v0.a8;
	var translation = _v0.cQ;
	return _Utils_Tuple2(
		{a8: baseUrl, bm: $elm$core$Maybe$Nothing, Z: _List_Nil, S: '', cP: today, cQ: translation, cX: false},
		$elm$core$Platform$Cmd$none);
};
var $author$project$Create$CreateModel$CreatedProjectInfo = F2(
	function (projectKey, secretKey) {
		return {cr: projectKey, cI: secretKey};
	});
var $author$project$Create$CreateModel$ProjectCreated = function (a) {
	return {$: 6, a: a};
};
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $author$project$Create$CreateUpdate$createdProjectInfo = _Platform_incomingPort('createdProjectInfo', $elm$json$Json$Decode$value);
var $author$project$Create$CreateUpdate$subscriptions = function (_v0) {
	var decoder = A3(
		$elm$json$Json$Decode$map2,
		$author$project$Create$CreateModel$CreatedProjectInfo,
		A2($elm$json$Json$Decode$field, 'projectKey', $elm$json$Json$Decode$string),
		A2($elm$json$Json$Decode$field, 'secretKey', $elm$json$Json$Decode$string));
	var decodeCreatedProjectInfo = function (v) {
		return A2($elm$json$Json$Decode$decodeValue, decoder, v);
	};
	var decoderResult = function (v) {
		var _v1 = decodeCreatedProjectInfo(v);
		if (!_v1.$) {
			var value = _v1.a;
			return value;
		} else {
			return {cr: 'error', cI: 'error'};
		}
	};
	return $author$project$Create$CreateUpdate$createdProjectInfo(
		function (v) {
			return $author$project$Create$CreateModel$ProjectCreated(
				decoderResult(v));
		});
};
var $author$project$Create$CreateModel$NoOp = {$: 8};
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$Task$onError = _Scheduler_onError;
var $elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return $elm$core$Task$command(
			A2(
				$elm$core$Task$onError,
				A2(
					$elm$core$Basics$composeL,
					A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
					$elm$core$Result$Err),
				A2(
					$elm$core$Task$andThen,
					A2(
						$elm$core$Basics$composeL,
						A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
						$elm$core$Result$Ok),
					task)));
	});
var $author$project$Common$ListUtils$changeIndex = F3(
	function (fn, index, list) {
		var mapper = F2(
			function (i, item) {
				return _Utils_eq(i, index) ? fn(item) : item;
			});
		return A2($elm$core$List$indexedMap, mapper, list);
	});
var $author$project$PollEditor$PollEditorModel$DatePollEditor = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$core$Set$Set_elm_builtin = $elm$core$Basics$identity;
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Set$empty = $elm$core$Dict$empty;
var $author$project$SDate$SDate$monthFromDay = function (_v0) {
	var sMonth = _v0.a;
	return sMonth;
};
var $author$project$Create$CreateUpdate$emptyDatePoll = function (today) {
	var state = {
		bG: $elm$core$Maybe$Nothing,
		bS: $author$project$SDate$SDate$monthFromDay(today),
		cP: today
	};
	var editor = A2(
		$author$project$PollEditor$PollEditorModel$DatePollEditor,
		state,
		{af: $elm$core$Set$empty, ar: $elm$core$Set$empty, aB: _List_Nil, aZ: $elm$core$Set$empty});
	return {bd: $elm$core$Maybe$Nothing, be: $elm$core$Maybe$Nothing, bt: editor, aA: '', aC: ''};
};
var $author$project$PollEditor$PollEditorModel$GenericPollEditor = function (a) {
	return {$: 1, a: a};
};
var $author$project$Create$CreateUpdate$emptyGenericPoll = function () {
	var editor = $author$project$PollEditor$PollEditorModel$GenericPollEditor(
		{
			af: _List_fromArray(
				['', '']),
			ar: $elm$core$Set$empty,
			aB: _List_Nil,
			cy: $elm$core$Dict$empty,
			aZ: $elm$core$Set$empty
		});
	return {bd: $elm$core$Maybe$Nothing, be: $elm$core$Maybe$Nothing, bt: editor, aA: '', aC: ''};
}();
var $elm$json$Json$Encode$bool = _Json_wrap;
var $author$project$Data$DataModel$commentIdInt = function (_v0) {
	var id = _v0;
	return id;
};
var $author$project$SDate$SDate$dayToTuple = function (_v0) {
	var _v1 = _v0.a;
	var year = _v1.a;
	var month = _v1.b;
	var day = _v0.b;
	return _Utils_Tuple3(year, month, day);
};
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === -2) {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$json$Json$Encode$dict = F3(
	function (toKey, toValue, dictionary) {
		return _Json_wrap(
			A3(
				$elm$core$Dict$foldl,
				F3(
					function (key, value, obj) {
						return A3(
							_Json_addField,
							toKey(key),
							toValue(value),
							obj);
					}),
				_Json_emptyObject(0),
				dictionary));
	});
var $elm$json$Json$Encode$int = _Json_wrap;
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(0),
			pairs));
};
var $author$project$Common$CommonEncoders$encodeDayTuple = function (_v0) {
	var y = _v0.a;
	var m = _v0.b;
	var d = _v0.c;
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'year',
				$elm$json$Json$Encode$int(y)),
				_Utils_Tuple2(
				'month',
				$elm$json$Json$Encode$int(m)),
				_Utils_Tuple2(
				'day',
				$elm$json$Json$Encode$int(d))
			]));
};
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(0),
				entries));
	});
var $author$project$Data$DataModel$optionIdInt = function (_v0) {
	var id = _v0;
	return id;
};
var $author$project$Data$DataModel$personIdInt = function (_v0) {
	var id = _v0;
	return id;
};
var $author$project$Data$DataModel$pollIdInt = function (_v0) {
	var id = _v0;
	return id;
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Data$DataEncoders$withLast = F3(
	function (fn, _default, list) {
		return A3(
			$elm$core$List$foldl,
			F2(
				function (item, _v0) {
					return fn(item);
				}),
			_default,
			list);
	});
var $author$project$Data$DataEncoders$encodeProject = function (project) {
	var selectedOptionToString = function (selectedOption) {
		switch (selectedOption) {
			case 0:
				return 'yes';
			case 1:
				return 'no';
			default:
				return 'ifNeeded';
		}
	};
	var encodeSelectedOptions = function (selectedOptions) {
		return A3(
			$elm$json$Json$Encode$dict,
			$elm$core$String$fromInt,
			function (v) {
				return $elm$json$Json$Encode$string(
					selectedOptionToString(v));
			},
			selectedOptions);
	};
	var encodePersonRow = function (personRow) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'id',
					$elm$json$Json$Encode$int(
						$author$project$Data$DataModel$personIdInt(personRow.cd))),
					_Utils_Tuple2(
					'name',
					$elm$json$Json$Encode$string(personRow.bU)),
					_Utils_Tuple2(
					'options',
					encodeSelectedOptions(personRow.cJ))
				]));
	};
	var encodeGenericItem = function (item) {
		return $elm$json$Json$Encode$object(
			_Utils_ap(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'id',
						$elm$json$Json$Encode$int(
							$author$project$Data$DataModel$optionIdInt(item.az))),
						_Utils_Tuple2(
						'value',
						$elm$json$Json$Encode$string(item.a_))
					]),
				item.aq ? _List_fromArray(
					[
						_Utils_Tuple2(
						'hidden',
						$elm$json$Json$Encode$bool(true))
					]) : _List_Nil));
	};
	var encodeDateItem = function (item) {
		return $elm$json$Json$Encode$object(
			_Utils_ap(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'id',
						$elm$json$Json$Encode$int(
							$author$project$Data$DataModel$optionIdInt(item.az))),
						_Utils_Tuple2(
						'value',
						$author$project$Common$CommonEncoders$encodeDayTuple(
							$author$project$SDate$SDate$dayToTuple(item.a_)))
					]),
				item.aq ? _List_fromArray(
					[
						_Utils_Tuple2(
						'hidden',
						$elm$json$Json$Encode$bool(true))
					]) : _List_Nil));
	};
	var encodePollInfo = function (info) {
		if (info.$ === 1) {
			var items = info.a.at;
			return $elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'type',
						$elm$json$Json$Encode$string('generic')),
						_Utils_Tuple2(
						'items',
						A2($elm$json$Json$Encode$list, encodeGenericItem, items)),
						_Utils_Tuple2(
						'lastItemId',
						$elm$json$Json$Encode$int(
							A3(
								$author$project$Data$DataEncoders$withLast,
								function (i) {
									return $author$project$Data$DataModel$optionIdInt(i.az);
								},
								0,
								items)))
					]));
		} else {
			var items = info.a.at;
			return $elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'type',
						$elm$json$Json$Encode$string('date')),
						_Utils_Tuple2(
						'items',
						A2($elm$json$Json$Encode$list, encodeDateItem, items)),
						_Utils_Tuple2(
						'lastItemId',
						$elm$json$Json$Encode$int(
							A3(
								$author$project$Data$DataEncoders$withLast,
								function (i) {
									return $author$project$Data$DataModel$optionIdInt(i.az);
								},
								0,
								items)))
					]));
		}
	};
	var encodeComment = function (comment) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'id',
					$elm$json$Json$Encode$int(
						$author$project$Data$DataModel$commentIdInt(comment.bj))),
					_Utils_Tuple2(
					'text',
					$elm$json$Json$Encode$string(comment.cO))
				]));
	};
	var descriptionToFieldEncoder = function (description) {
		if (description.$ === 1) {
			return _List_Nil;
		} else {
			var desc = description.a;
			return _List_fromArray(
				[
					_Utils_Tuple2(
					'description',
					$elm$json$Json$Encode$string(desc))
				]);
		}
	};
	var encodePoll = function (_v0) {
		var pollId = _v0.ci;
		var title = _v0.S;
		var description = _v0.bp;
		var pollInfo = _v0.cj;
		var personRows = _v0.ce;
		var lastPersonId = _v0.bN;
		return $elm$json$Json$Encode$object(
			_Utils_ap(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'title',
						$elm$json$Json$Encode$string(
							A2($elm$core$Maybe$withDefault, '', title))),
						_Utils_Tuple2(
						'def',
						encodePollInfo(pollInfo)),
						_Utils_Tuple2(
						'id',
						$elm$json$Json$Encode$int(
							$author$project$Data$DataModel$pollIdInt(pollId))),
						_Utils_Tuple2(
						'lastPersonId',
						$elm$json$Json$Encode$int(lastPersonId)),
						_Utils_Tuple2(
						'people',
						A2($elm$json$Json$Encode$list, encodePersonRow, personRows))
					]),
				descriptionToFieldEncoder(description)));
	};
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'title',
				$elm$json$Json$Encode$string(
					A2($elm$core$Maybe$withDefault, '', project.S))),
				_Utils_Tuple2(
				'polls',
				A2($elm$json$Json$Encode$list, encodePoll, project.Z)),
				_Utils_Tuple2(
				'lastPollId',
				$elm$json$Json$Encode$int(project.bO)),
				_Utils_Tuple2(
				'comments',
				A2($elm$json$Json$Encode$list, encodeComment, project.bk)),
				_Utils_Tuple2(
				'lastCommentId',
				$elm$json$Json$Encode$int(project.bM))
			]));
};
var $elm$browser$Browser$Dom$getViewportOf = _Browser_getViewportOf;
var $author$project$Data$DataModel$DatePollInfo = function (a) {
	return {$: 0, a: a};
};
var $author$project$Data$DataModel$GenericPollInfo = function (a) {
	return {$: 1, a: a};
};
var $author$project$Data$DataModel$OptionId = $elm$core$Basics$identity;
var $author$project$Data$DataModel$PollId = $elm$core$Basics$identity;
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $author$project$Common$ListUtils$filterNothings = function (list) {
	return A3(
		$elm$core$List$foldr,
		F2(
			function (curr, acc) {
				if (!curr.$) {
					var a = curr.a;
					return A2($elm$core$List$cons, a, acc);
				} else {
					return acc;
				}
			}),
		_List_Nil,
		list);
};
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$String$trim = _String_trim;
var $author$project$Common$CommonUtils$normalizeStringMaybe = function (strOpt) {
	return A2(
		$elm$core$Maybe$andThen,
		function (s) {
			return $elm$core$String$isEmpty(s) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(s);
		},
		A2($elm$core$Maybe$map, $elm$core$String$trim, strOpt));
};
var $elm$core$Basics$not = _Basics_not;
var $author$project$Common$CommonUtils$stringToMaybe = function (s) {
	var trimmed = $elm$core$String$trim(s);
	if (trimmed === '') {
		return $elm$core$Maybe$Nothing;
	} else {
		var x = trimmed;
		return $elm$core$Maybe$Just(x);
	}
};
var $author$project$Create$CreateModel$newPollsToProject = function (_v0) {
	var title = _v0.S;
	var polls = _v0.Z;
	var newGenericPollDataToPollInfo = function (_v3) {
		var addedItems = _v3.af;
		return A2(
			$elm$core$List$indexedMap,
			F2(
				function (index, item) {
					return {aq: false, az: 1 + index, a_: item};
				}),
			A2(
				$elm$core$List$filter,
				function (v) {
					return !$elm$core$String$isEmpty(
						$elm$core$String$trim(v));
				},
				addedItems));
	};
	var newDatePollDataToPollInfo = function (_v2) {
		var addedItems = _v2.af;
		return A2(
			$elm$core$List$indexedMap,
			F2(
				function (index, item) {
					return {aq: false, az: 1 + index, a_: item};
				}),
			$author$project$Common$ListUtils$filterNothings(
				A2(
					$elm$core$List$map,
					$author$project$SDate$SDate$dayFromTuple,
					$elm$core$Set$toList(addedItems))));
	};
	var newPollModelToPollInfo = function (pollEditorModel) {
		if (!pollEditorModel.$) {
			var newPollData = pollEditorModel.b;
			return $author$project$Data$DataModel$DatePollInfo(
				{
					at: newDatePollDataToPollInfo(newPollData)
				});
		} else {
			var newPollData = pollEditorModel.a;
			return $author$project$Data$DataModel$GenericPollInfo(
				{
					at: newGenericPollDataToPollInfo(newPollData)
				});
		}
	};
	var pollEditorModelToPoll = F2(
		function (index, pollEditorModel) {
			return {
				bp: $author$project$Common$CommonUtils$normalizeStringMaybe(pollEditorModel.bd),
				bN: 0,
				ce: _List_Nil,
				ci: index + 1,
				cj: newPollModelToPollInfo(pollEditorModel.bt),
				S: $author$project$Common$CommonUtils$normalizeStringMaybe(pollEditorModel.be)
			};
		});
	var finalPolls = A2($elm$core$List$indexedMap, pollEditorModelToPoll, polls);
	return {
		bk: _List_Nil,
		bM: 0,
		bO: 1 + $elm$core$List$length(finalPolls),
		Z: finalPolls,
		S: $author$project$Common$CommonUtils$stringToMaybe(title)
	};
};
var $author$project$Create$CreateUpdate$persist = _Platform_outgoingPort('persist', $elm$core$Basics$identity);
var $author$project$Common$ListUtils$removeIndex = F2(
	function (index, list) {
		var fn = F2(
			function (a, _v1) {
				var i = _v1.a;
				var res = _v1.b;
				return _Utils_eq(i, index) ? _Utils_Tuple2(i + 1, res) : _Utils_Tuple2(
					i + 1,
					A2($elm$core$List$cons, a, res));
			});
		var _v0 = A3(
			$elm$core$List$foldl,
			fn,
			_Utils_Tuple2(0, _List_Nil),
			list);
		var reversed = _v0.b;
		return $elm$core$List$reverse(reversed);
	});
var $elm$browser$Browser$Dom$setViewport = _Browser_setViewport;
var $author$project$PollEditor$PollEditorUpdate$addGenericItem = function (data) {
	return _Utils_update(
		data,
		{
			af: _Utils_ap(
				data.af,
				_List_fromArray(
					['']))
		});
};
var $elm$core$Dict$Black = 1;
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = 0;
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1) {
				case 0:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Set$insert = F2(
	function (key, _v0) {
		var dict = _v0;
		return A3($elm$core$Dict$insert, key, 0, dict);
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === -1) && (dict.d.$ === -1)) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === -1) && (!left.a)) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === -1) && (right.a === 1)) {
					if (right.d.$ === -1) {
						if (right.d.a === 1) {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === -1) && (dict.d.$ === -1)) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor === 1) {
			if ((lLeft.$ === -1) && (!lLeft.a)) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === -1) {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === -2) {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === -1) && (left.a === 1)) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === -1) && (!lLeft.a)) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === -1) {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === -1) {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === -1) {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Set$remove = F2(
	function (key, _v0) {
		var dict = _v0;
		return A2($elm$core$Dict$remove, key, dict);
	});
var $author$project$PollEditor$PollEditorUpdate$deselectDate = F2(
	function (dayTuple, data) {
		var sDayOpt = $author$project$SDate$SDate$dayFromTuple(dayTuple);
		var originalDateOptionItem = A2(
			$elm$core$Maybe$andThen,
			function (sDay) {
				return A2(
					$author$project$Common$ListUtils$findFirst,
					function (i) {
						return _Utils_eq(i.a_, sDay);
					},
					data.aB);
			},
			sDayOpt);
		var res = function () {
			if (!originalDateOptionItem.$) {
				var optionItem = originalDateOptionItem.a;
				return optionItem.aq ? _Utils_update(
					data,
					{
						aZ: A2(
							$elm$core$Set$remove,
							$author$project$Data$DataModel$optionIdInt(optionItem.az),
							data.aZ)
					}) : _Utils_update(
					data,
					{
						ar: A2(
							$elm$core$Set$insert,
							$author$project$Data$DataModel$optionIdInt(optionItem.az),
							data.ar)
					});
			} else {
				return _Utils_update(
					data,
					{
						af: A2($elm$core$Set$remove, dayTuple, data.af)
					});
			}
		}();
		if (!sDayOpt.$) {
			return res;
		} else {
			return data;
		}
	});
var $author$project$PollEditor$PollEditorUpdate$doWithDatePoll = F2(
	function (fn, model) {
		var _v0 = model.bt;
		if (!_v0.$) {
			var state = _v0.a;
			var datePollData = _v0.b;
			return _Utils_update(
				model,
				{
					bt: A2(
						$author$project$PollEditor$PollEditorModel$DatePollEditor,
						state,
						fn(datePollData))
				});
		} else {
			return model;
		}
	});
var $author$project$PollEditor$PollEditorUpdate$doWithDatePollState = F2(
	function (fn, model) {
		var _v0 = model.bt;
		if (!_v0.$) {
			var state = _v0.a;
			var datePollData = _v0.b;
			return _Utils_update(
				model,
				{
					bt: A2(
						$author$project$PollEditor$PollEditorModel$DatePollEditor,
						fn(state),
						datePollData)
				});
		} else {
			return model;
		}
	});
var $author$project$PollEditor$PollEditorUpdate$doWithGenericPoll = F2(
	function (fn, model) {
		var _v0 = model.bt;
		if (_v0.$ === 1) {
			var genericPollData = _v0.a;
			return _Utils_update(
				model,
				{
					bt: $author$project$PollEditor$PollEditorModel$GenericPollEditor(
						fn(genericPollData))
				});
		} else {
			return model;
		}
	});
var $author$project$PollEditor$PollEditorUpdate$hideGenericItem = F2(
	function (optionId, pollData) {
		var originallyHidden = A2(
			$elm$core$Maybe$withDefault,
			false,
			A2(
				$elm$core$Maybe$map,
				function ($) {
					return $.aq;
				},
				A2(
					$author$project$Common$ListUtils$findFirst,
					function (i) {
						return _Utils_eq(i.az, optionId);
					},
					pollData.aB)));
		return originallyHidden ? _Utils_update(
			pollData,
			{
				aZ: A2(
					$elm$core$Set$remove,
					$author$project$Data$DataModel$optionIdInt(optionId),
					pollData.aZ)
			}) : _Utils_update(
			pollData,
			{
				ar: A2(
					$elm$core$Set$insert,
					$author$project$Data$DataModel$optionIdInt(optionId),
					pollData.ar)
			});
	});
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $author$project$PollEditor$PollEditorUpdate$removeGenericItem = F2(
	function (itemNumber, data) {
		var newItems = (($elm$core$List$length(data.af) > 1) || (!$elm$core$List$isEmpty(data.aB))) ? A2($author$project$Common$ListUtils$removeIndex, itemNumber, data.af) : A3(
			$author$project$Common$ListUtils$changeIndex,
			function (_v0) {
				return '';
			},
			itemNumber,
			data.af);
		return _Utils_update(
			data,
			{af: newItems});
	});
var $author$project$PollEditor$PollEditorUpdate$renameGenericItem = F3(
	function (optionId, value, pollData) {
		var valueOpt = A2(
			$elm$core$Maybe$map,
			function ($) {
				return $.a_;
			},
			A2(
				$author$project$Common$ListUtils$findFirst,
				function (i) {
					return _Utils_eq(i.az, optionId);
				},
				pollData.aB));
		var newRenamedItems = _Utils_eq(
			$elm$core$Maybe$Just(value),
			valueOpt) ? A2(
			$elm$core$Dict$remove,
			$author$project$Data$DataModel$optionIdInt(optionId),
			pollData.cy) : A3(
			$elm$core$Dict$insert,
			$author$project$Data$DataModel$optionIdInt(optionId),
			value,
			pollData.cy);
		return _Utils_update(
			pollData,
			{cy: newRenamedItems});
	});
var $author$project$PollEditor$PollEditorUpdate$selectDate = F2(
	function (dayTuple, data) {
		var sDayOpt = $author$project$SDate$SDate$dayFromTuple(dayTuple);
		var originalDateOptionItem = A2(
			$elm$core$Maybe$andThen,
			function (sDay) {
				return A2(
					$author$project$Common$ListUtils$findFirst,
					function (i) {
						return _Utils_eq(i.a_, sDay);
					},
					data.aB);
			},
			sDayOpt);
		var res = function () {
			if (!originalDateOptionItem.$) {
				var optionItem = originalDateOptionItem.a;
				return optionItem.aq ? _Utils_update(
					data,
					{
						aZ: A2(
							$elm$core$Set$insert,
							$author$project$Data$DataModel$optionIdInt(optionItem.az),
							data.aZ)
					}) : _Utils_update(
					data,
					{
						ar: A2(
							$elm$core$Set$remove,
							$author$project$Data$DataModel$optionIdInt(optionItem.az),
							data.ar)
					});
			} else {
				return _Utils_update(
					data,
					{
						af: A2($elm$core$Set$insert, dayTuple, data.af)
					});
			}
		}();
		if (!sDayOpt.$) {
			return res;
		} else {
			return data;
		}
	});
var $author$project$SDate$SDate$monthToTuple = function (_v0) {
	var year = _v0.a;
	var month = _v0.b;
	return _Utils_Tuple2(year, month);
};
var $author$project$PollEditor$PollEditorUpdate$setCalendarMonthDirect = F2(
	function (str, data) {
		var monthOpt = $elm$core$String$toInt(str);
		var _v0 = $author$project$SDate$SDate$monthToTuple(data.bS);
		var year = _v0.a;
		var newMonthOpt = A2(
			$elm$core$Maybe$andThen,
			function (m) {
				return $author$project$SDate$SDate$monthFromTuple(
					_Utils_Tuple2(year, m));
			},
			monthOpt);
		if (!newMonthOpt.$) {
			var sMonth = newMonthOpt.a;
			return _Utils_update(
				data,
				{bS: sMonth});
		} else {
			return data;
		}
	});
var $author$project$PollEditor$PollEditorUpdate$setCalendarYearDirect = F2(
	function (str, data) {
		var yearOpt = $elm$core$String$toInt(str);
		var _v0 = $author$project$SDate$SDate$monthToTuple(data.bS);
		var month = _v0.b;
		var newYearOpt = A2(
			$elm$core$Maybe$andThen,
			function (y) {
				return $author$project$SDate$SDate$monthFromTuple(
					_Utils_Tuple2(y, month));
			},
			yearOpt);
		if (!newYearOpt.$) {
			var sMonth = newYearOpt.a;
			return _Utils_update(
				data,
				{bS: sMonth});
		} else {
			return data;
		}
	});
var $author$project$PollEditor$PollEditorUpdate$setNewGenericItem = F3(
	function (itemNumber, newValue, data) {
		return _Utils_update(
			data,
			{
				af: A3(
					$author$project$Common$ListUtils$changeIndex,
					function (_v0) {
						return newValue;
					},
					itemNumber,
					data.af)
			});
	});
var $author$project$PollEditor$PollEditorUpdate$setPollDescription = F2(
	function (newDescription, model) {
		var newChangedDescription = _Utils_eq(newDescription, model.aA) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(newDescription);
		return _Utils_update(
			model,
			{bd: newChangedDescription});
	});
var $author$project$PollEditor$PollEditorUpdate$setPollTitle = F2(
	function (newTitle, model) {
		var newChangedTitle = _Utils_eq(newTitle, model.aC) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(newTitle);
		return _Utils_update(
			model,
			{be: newChangedTitle});
	});
var $author$project$PollEditor$PollEditorUpdate$unhideGenericItem = F2(
	function (optionId, pollData) {
		var originallyHidden = A2(
			$elm$core$Maybe$withDefault,
			false,
			A2(
				$elm$core$Maybe$map,
				function ($) {
					return $.aq;
				},
				A2(
					$author$project$Common$ListUtils$findFirst,
					function (i) {
						return _Utils_eq(i.az, optionId);
					},
					pollData.aB)));
		return originallyHidden ? _Utils_update(
			pollData,
			{
				aZ: A2(
					$elm$core$Set$insert,
					$author$project$Data$DataModel$optionIdInt(optionId),
					pollData.aZ)
			}) : _Utils_update(
			pollData,
			{
				ar: A2(
					$elm$core$Set$remove,
					$author$project$Data$DataModel$optionIdInt(optionId),
					pollData.ar)
			});
	});
var $author$project$PollEditor$PollEditorUpdate$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 0:
				var title = msg.a;
				return A2($author$project$PollEditor$PollEditorUpdate$setPollTitle, title, model);
			case 1:
				var description = msg.a;
				return A2($author$project$PollEditor$PollEditorUpdate$setPollDescription, description, model);
			case 2:
				var itemNumber = msg.a;
				var itemVal = msg.b;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithGenericPoll,
					A2($author$project$PollEditor$PollEditorUpdate$setNewGenericItem, itemNumber, itemVal),
					model);
			case 3:
				return A2($author$project$PollEditor$PollEditorUpdate$doWithGenericPoll, $author$project$PollEditor$PollEditorUpdate$addGenericItem, model);
			case 4:
				var itemNumber = msg.a;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithGenericPoll,
					$author$project$PollEditor$PollEditorUpdate$removeGenericItem(itemNumber),
					model);
			case 5:
				var optionId = msg.a;
				var value = msg.b;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithGenericPoll,
					A2($author$project$PollEditor$PollEditorUpdate$renameGenericItem, optionId, value),
					model);
			case 6:
				var optionId = msg.a;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithGenericPoll,
					$author$project$PollEditor$PollEditorUpdate$hideGenericItem(optionId),
					model);
			case 7:
				var optionId = msg.a;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithGenericPoll,
					$author$project$PollEditor$PollEditorUpdate$unhideGenericItem(optionId),
					model);
			case 8:
				var dayTuple = msg.a;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithDatePoll,
					$author$project$PollEditor$PollEditorUpdate$selectDate(dayTuple),
					model);
			case 9:
				var dayTuple = msg.a;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithDatePoll,
					$author$project$PollEditor$PollEditorUpdate$deselectDate(dayTuple),
					model);
			case 10:
				var sMonth = msg.a;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithDatePollState,
					function (state) {
						return _Utils_update(
							state,
							{bS: sMonth});
					},
					model);
			case 11:
				var str = msg.a;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithDatePollState,
					$author$project$PollEditor$PollEditorUpdate$setCalendarMonthDirect(str),
					model);
			case 12:
				var str = msg.a;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithDatePollState,
					$author$project$PollEditor$PollEditorUpdate$setCalendarYearDirect(str),
					model);
			case 13:
				var maybeTuple = msg.a;
				return A2(
					$author$project$PollEditor$PollEditorUpdate$doWithDatePollState,
					function (state) {
						return _Utils_update(
							state,
							{bG: maybeTuple});
					},
					model);
			default:
				return model;
		}
	});
var $author$project$Create$CreateUpdate$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 8:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 0:
				var newTitle = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{S: newTitle}),
					$elm$core$Platform$Cmd$none);
			case 1:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							Z: _Utils_ap(
								model.Z,
								_List_fromArray(
									[$author$project$Create$CreateUpdate$emptyGenericPoll]))
						}),
					$elm$core$Platform$Cmd$none);
			case 2:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							Z: _Utils_ap(
								model.Z,
								_List_fromArray(
									[
										$author$project$Create$CreateUpdate$emptyDatePoll(model.cP)
									]))
						}),
					$elm$core$Platform$Cmd$none);
			case 3:
				var num = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							Z: A2($author$project$Common$ListUtils$removeIndex, num, model.Z)
						}),
					$elm$core$Platform$Cmd$none);
			case 4:
				var num = msg.a;
				var pollEditorMsg = msg.b;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							Z: A3(
								$author$project$Common$ListUtils$changeIndex,
								$author$project$PollEditor$PollEditorUpdate$update(pollEditorMsg),
								num,
								model.Z)
						}),
					$elm$core$Platform$Cmd$none);
			case 5:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{cX: true}),
					$author$project$Create$CreateUpdate$persist(
						$author$project$Data$DataEncoders$encodeProject(
							$author$project$Create$CreateModel$newPollsToProject(model))));
			case 6:
				var projectInfo = msg.a;
				var scroll = function (id) {
					return A2(
						$elm$core$Task$attempt,
						function (_v1) {
							return $author$project$Create$CreateModel$NoOp;
						},
						A2(
							$elm$core$Task$andThen,
							function (info) {
								return A2($elm$browser$Browser$Dom$setViewport, 0, info.cV.c_);
							},
							$elm$browser$Browser$Dom$getViewportOf(id)));
				};
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							bm: $elm$core$Maybe$Just(projectInfo)
						}),
					scroll('project'));
			default:
				var code = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							cQ: $author$project$Translations$Translations$get(code)
						}),
					$elm$core$Platform$Cmd$none);
		}
	});
var $elm$html$Html$a = _VirtualDom_node('a');
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$core$String$concat = function (strings) {
	return A2($elm$core$String$join, '', strings);
};
var $elm$html$Html$div = _VirtualDom_node('div');
var $elm$html$Html$Attributes$href = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'href',
		_VirtualDom_noJavaScriptUri(url));
};
var $elm$html$Html$p = _VirtualDom_node('p');
var $elm$html$Html$span = _VirtualDom_node('span');
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $author$project$Create$CreateView$viewCreated = F2(
	function (_v0, model) {
		var projectKey = _v0.cr;
		var secretKey = _v0.cI;
		var urlBase = $elm$core$String$concat(
			_List_fromArray(
				[model.a8, '/v01/vote.html#', projectKey, '/']));
		var url = $elm$core$String$concat(
			_List_fromArray(
				[urlBase, secretKey]));
		return A2(
			$elm$html$Html$div,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('project-created-title')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(
							$elm$core$String$isEmpty(
								$elm$core$String$trim(model.S)) ? model.cQ.r.cS : model.S)
						])),
					A2(
					$elm$html$Html$div,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_Nil,
							_List_fromArray(
								[
									A2(
									$elm$html$Html$p,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('project-created-info-main')
										]),
									_List_fromArray(
										[
											$elm$html$Html$text(model.cQ.n.cq)
										])),
									A2(
									$elm$html$Html$p,
									_List_Nil,
									_List_fromArray(
										[
											$elm$html$Html$text(model.cQ.n.co)
										])),
									A2(
									$elm$html$Html$p,
									_List_Nil,
									_List_fromArray(
										[
											$elm$html$Html$text(model.cQ.n.cp)
										]))
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('project-created-link-box')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$a,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('project-created-link'),
											$elm$html$Html$Attributes$href(url)
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$span,
											_List_Nil,
											_List_fromArray(
												[
													$elm$html$Html$text(urlBase)
												])),
											A2(
											$elm$html$Html$span,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('project-created-link-secret')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text(secretKey)
												]))
										]))
								]))
						]))
				]));
	});
var $author$project$Create$CreateModel$AddDatePoll = {$: 2};
var $author$project$Create$CreateModel$AddGenericPoll = {$: 1};
var $author$project$Create$CreateModel$EditPoll = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var $author$project$Create$CreateModel$RemovePoll = function (a) {
	return {$: 3, a: a};
};
var $author$project$Create$CreateModel$SetTitle = function (a) {
	return {$: 0, a: a};
};
var $author$project$Create$CreateModel$SetTranslation = function (a) {
	return {$: 7, a: a};
};
var $elm$html$Html$b = _VirtualDom_node('b');
var $elm$html$Html$button = _VirtualDom_node('button');
var $elm$html$Html$h2 = _VirtualDom_node('h2');
var $elm$html$Html$input = _VirtualDom_node('input');
var $elm$html$Html$label = _VirtualDom_node('label');
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 0, a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 1, a: a};
};
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $elm$html$Html$Attributes$placeholder = $elm$html$Html$Attributes$stringProperty('placeholder');
var $author$project$Create$CreateModel$Persist = {$: 5};
var $elm$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			$elm$core$List$any,
			A2($elm$core$Basics$composeL, $elm$core$Basics$not, isOkay),
			list);
	});
var $elm$html$Html$Attributes$boolProperty = F2(
	function (key, bool) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$bool(bool));
	});
var $elm$html$Html$Attributes$disabled = $elm$html$Html$Attributes$boolProperty('disabled');
var $elm$core$Dict$isEmpty = function (dict) {
	if (dict.$ === -2) {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Set$isEmpty = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$isEmpty(dict);
};
var $author$project$Create$CreateView$submitButton = function (model) {
	var genericPollValid = function (items) {
		return A2(
			$elm$core$List$all,
			function (s) {
				return !$elm$core$String$isEmpty(
					$elm$core$String$trim(s));
			},
			items);
	};
	var pollValid = function (_v1) {
		var editor = _v1.bt;
		if (!editor.$) {
			var addedItems = editor.b.af;
			return !$elm$core$Set$isEmpty(addedItems);
		} else {
			var addedItems = editor.a.af;
			return (!$elm$core$List$isEmpty(addedItems)) && genericPollValid(addedItems);
		}
	};
	var empty = $elm$core$List$isEmpty(model.Z);
	var buttonText = model.cX ? _List_fromArray(
		[
			$elm$html$Html$text(model.cQ.r.cY)
		]) : _List_fromArray(
		[
			$elm$html$Html$text(
			model.cQ.n.bl(
				$elm$core$List$length(model.Z)))
		]);
	var allValid = A2($elm$core$List$all, pollValid, model.Z);
	var disabledVal = empty || ((!allValid) || model.cX);
	return A2(
		$elm$html$Html$button,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('submit-button common-button colors-add'),
				$elm$html$Html$Attributes$disabled(disabledVal),
				$elm$html$Html$Events$onClick($author$project$Create$CreateModel$Persist)
			]),
		buttonText);
};
var $elm$html$Html$Attributes$title = $elm$html$Html$Attributes$stringProperty('title');
var $author$project$Translations$TranslationsView$translationsView = F2(
	function (current, message) {
		var currentClass = function (translation) {
			return _Utils_eq(translation.bi, current.bi) ? ' translation-item-selected' : '';
		};
		var translationToItem = function (translation) {
			return A2(
				$elm$html$Html$a,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class(
						'translation-item' + currentClass(translation)),
						$elm$html$Html$Attributes$title(translation.bU),
						$elm$html$Html$Events$onClick(
						message(translation.bi))
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(translation.bi)
					]));
		};
		var items = A2($elm$core$List$map, translationToItem, $author$project$Translations$Translations$available);
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('translation-base-line')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('translation-list')
						]),
					items)
				]));
	});
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $elm$html$Html$Attributes$value = $elm$html$Html$Attributes$stringProperty('value');
var $author$project$Common$CommonView$viewBoxInfo = function (string) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('box-info')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('box-info-icon')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('i')
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('box-info-text')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(string)
					]))
			]));
};
var $elm$html$Html$Attributes$tabindex = function (n) {
	return A2(
		_VirtualDom_attribute,
		'tabIndex',
		$elm$core$String$fromInt(n));
};
var $author$project$Create$CreateView$viewChooseFirstPoll = function (translation) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$a,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('polls-empty-add'),
						$elm$html$Html$Events$onClick($author$project$Create$CreateModel$AddDatePoll),
						$elm$html$Html$Attributes$tabindex(0)
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('polls-empty-add-title')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('+ ' + translation.r.aI)
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('polls-empty-add-description')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(translation.n.cg)
							]))
					])),
				A2(
				$elm$html$Html$a,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('polls-empty-add'),
						$elm$html$Html$Events$onClick($author$project$Create$CreateModel$AddGenericPoll),
						$elm$html$Html$Attributes$tabindex(0)
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('polls-empty-add-title')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('+ ' + translation.r.aJ)
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('polls-empty-add-description')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(translation.n.ch)
							]))
					]))
			]));
};
var $author$project$PollEditor$PollEditorModel$SetPollDescription = function (a) {
	return {$: 1, a: a};
};
var $author$project$PollEditor$PollEditorModel$SetPollTitle = function (a) {
	return {$: 0, a: a};
};
var $elm$html$Html$textarea = _VirtualDom_node('textarea');
var $author$project$PollEditor$PollEditorModel$AddDatePollItem = function (a) {
	return {$: 8, a: a};
};
var $author$project$PollEditor$PollEditorModel$RemoveDatePollItem = function (a) {
	return {$: 9, a: a};
};
var $author$project$PollEditor$PollEditorModel$SetHighlightedDay = function (a) {
	return {$: 13, a: a};
};
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$member = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$get, key, dict);
		if (!_v0.$) {
			return true;
		} else {
			return false;
		}
	});
var $elm$core$Set$member = F2(
	function (key, _v0) {
		var dict = _v0;
		return A2($elm$core$Dict$member, key, dict);
	});
var $elm$html$Html$Events$onMouseEnter = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'mouseenter',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$html$Html$Events$onMouseLeave = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'mouseleave',
		$elm$json$Json$Decode$succeed(msg));
};
var $author$project$Common$CommonView$optClass = F2(
	function (present, name) {
		return present ? (' ' + name) : '';
	});
var $author$project$PollEditor$PollEditorView$viewDateCalendarCell = F4(
	function (state, pollData, viewConfig, sDay) {
		var originalDateOptionItem = A2(
			$author$project$Common$ListUtils$findFirst,
			function (i) {
				return _Utils_eq(i.a_, sDay);
			},
			pollData.aB);
		var originalSelected = function () {
			if (!originalDateOptionItem.$) {
				var dateOptionItem = originalDateOptionItem.a;
				return (!dateOptionItem.aq) && (!A2(
					$elm$core$Set$member,
					$author$project$Data$DataModel$optionIdInt(dateOptionItem.az),
					pollData.ar));
			} else {
				return false;
			}
		}();
		var dayTuple = $author$project$SDate$SDate$dayToTuple(sDay);
		var future = _Utils_cmp(
			dayTuple,
			$author$project$SDate$SDate$dayToTuple(viewConfig.cP)) > -1;
		var selected = originalSelected || A2($elm$core$Set$member, dayTuple, pollData.af);
		var onClickAction = selected ? viewConfig.cc(
			$author$project$PollEditor$PollEditorModel$RemoveDatePollItem(dayTuple)) : viewConfig.cc(
			$author$project$PollEditor$PollEditorModel$AddDatePollItem(dayTuple));
		var _v0 = dayTuple;
		var month = _v0.b;
		var date = _v0.c;
		var _v1 = $author$project$SDate$SDate$monthToTuple(state.bS);
		var activeMonth = _v1.b;
		var active = _Utils_eq(month, activeMonth);
		var cellClass = 'calendar-cell' + (A2($author$project$Common$CommonView$optClass, selected, 'calendar-cell-selected') + (A2($author$project$Common$CommonView$optClass, active, 'calendar-cell-active') + (A2($author$project$Common$CommonView$optClass, future, 'calendar-cell-future') + (A2(
			$author$project$Common$CommonView$optClass,
			_Utils_eq(
				state.bG,
				$elm$core$Maybe$Just(dayTuple)),
			'calendar-cell-highlighted') + A2(
			$author$project$Common$CommonView$optClass,
			_Utils_eq(state.cP, sDay),
			'calendar-cell-today')))));
		return A2(
			$elm$html$Html$a,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class(cellClass),
					$elm$html$Html$Events$onClick(onClickAction),
					$elm$html$Html$Events$onMouseEnter(
					viewConfig.cc(
						$author$project$PollEditor$PollEditorModel$SetHighlightedDay(
							$elm$core$Maybe$Just(dayTuple)))),
					$elm$html$Html$Events$onMouseLeave(
					viewConfig.cc(
						$author$project$PollEditor$PollEditorModel$SetHighlightedDay($elm$core$Maybe$Nothing))),
					$elm$html$Html$Attributes$tabindex(0)
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(
					$elm$core$String$fromInt(date))
				]));
	});
var $author$project$PollEditor$PollEditorModel$SetCalendarMonth = function (a) {
	return {$: 10, a: a};
};
var $author$project$PollEditor$PollEditorModel$SetCalendarMonthDirect = function (a) {
	return {$: 11, a: a};
};
var $author$project$PollEditor$PollEditorModel$SetCalendarYearDirect = function (a) {
	return {$: 12, a: a};
};
var $elm$html$Html$Attributes$min = $elm$html$Html$Attributes$stringProperty('min');
var $author$project$SDate$SDate$nextMonth = function (_v0) {
	var sYear = _v0.a;
	var year = sYear;
	var month = _v0.b;
	return (month === 12) ? A2($author$project$SDate$SDate$SMonth, year + 1, 1) : A2($author$project$SDate$SDate$SMonth, sYear, month + 1);
};
var $author$project$Common$CommonView$onChange = function (handler) {
	return A2(
		$elm$html$Html$Events$on,
		'change',
		A2(
			$elm$json$Json$Decode$map,
			handler,
			A2(
				$elm$json$Json$Decode$at,
				_List_fromArray(
					['target', 'value']),
				$elm$json$Json$Decode$string)));
};
var $elm$html$Html$option = _VirtualDom_node('option');
var $author$project$SDate$SDate$prevMonth = function (_v0) {
	var sYear = _v0.a;
	var year = sYear;
	var month = _v0.b;
	return (month === 1) ? A2($author$project$SDate$SDate$SMonth, year - 1, 12) : A2($author$project$SDate$SDate$SMonth, sYear, month - 1);
};
var $elm$html$Html$select = _VirtualDom_node('select');
var $elm$html$Html$Attributes$selected = $elm$html$Html$Attributes$boolProperty('selected');
var $author$project$PollEditor$PollEditorView$viewDateCalendarControls = F2(
	function (state, viewConfig) {
		var names = viewConfig.cQ.r.bT;
		var _v0 = $author$project$SDate$SDate$monthToTuple(state.bS);
		var year = _v0.a;
		var month = _v0.b;
		var nameToOption = F2(
			function (index, name) {
				return A2(
					$elm$html$Html$option,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$selected(
							_Utils_eq(index + 1, month)),
							$elm$html$Html$Attributes$value(
							$elm$core$String$fromInt(index + 1))
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(name)
						]));
			});
		var options = A2($elm$core$List$indexedMap, nameToOption, names);
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('calendar-controls')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('calendar-controls-direct')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$select,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('common-input common-select common-group-first calendar-controls-month'),
									$elm$html$Html$Events$onInput(
									A2($elm$core$Basics$composeL, viewConfig.cc, $author$project$PollEditor$PollEditorModel$SetCalendarMonthDirect))
								]),
							options),
							A2(
							$elm$html$Html$input,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('common-input common-group-last calendar-controls-year'),
									$elm$html$Html$Attributes$type_('number'),
									$elm$html$Html$Attributes$value(
									$elm$core$String$fromInt(year)),
									$elm$html$Html$Attributes$min('1970'),
									$author$project$Common$CommonView$onChange(
									A2($elm$core$Basics$composeL, viewConfig.cc, $author$project$PollEditor$PollEditorModel$SetCalendarYearDirect))
								]),
							_List_Nil)
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('calendar-controls-buttons')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('common-button common-input calendar-controls-buttons-today'),
									$elm$html$Html$Events$onClick(
									viewConfig.cc(
										$author$project$PollEditor$PollEditorModel$SetCalendarMonth(
											$author$project$SDate$SDate$monthFromDay(viewConfig.cP))))
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(viewConfig.cQ.r.cP)
								])),
							$elm$html$Html$text(' '),
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('common-button common-wide common-input common-group-first'),
									$elm$html$Html$Events$onClick(
									viewConfig.cc(
										$author$project$PollEditor$PollEditorModel$SetCalendarMonth(
											$author$project$SDate$SDate$prevMonth(state.bS))))
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(' < ')
								])),
							A2(
							$elm$html$Html$button,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('common-button common-wide common-input common-group-last'),
									$elm$html$Html$Events$onClick(
									viewConfig.cc(
										$author$project$PollEditor$PollEditorModel$SetCalendarMonth(
											$author$project$SDate$SDate$nextMonth(state.bS))))
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(' > ')
								]))
						]))
				]));
	});
var $author$project$PollEditor$PollEditorView$viewDateCalendarHeaderRow = function (translation) {
	var days = translation.r.bn;
	var dayToCell = function (day) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('calendar-cell calendar-header-cell')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text(day)
				]));
	};
	var cells = A2($elm$core$List$map, dayToCell, days);
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('calendar-row calendar-header-row')
			]),
		cells);
};
var $author$project$SDate$SDate$nextDay = function (_v0) {
	var sMonth = _v0.a;
	var day = _v0.b;
	return (_Utils_cmp(
		day,
		$author$project$SDate$SDate$daysInMonth(sMonth)) < 0) ? A2($author$project$SDate$SDate$SDay, sMonth, day + 1) : A2(
		$author$project$SDate$SDate$SDay,
		$author$project$SDate$SDate$nextMonth(sMonth),
		1);
};
var $elm$core$Elm$JsArray$foldl = _JsArray_foldl;
var $elm$core$Array$foldl = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldl, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldl, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldl,
			func,
			A3($elm$core$Elm$JsArray$foldl, helper, baseCase, tree),
			tail);
	});
var $elm$core$Elm$JsArray$push = _JsArray_push;
var $elm$core$Elm$JsArray$singleton = _JsArray_singleton;
var $elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
var $elm$core$Array$insertTailInTree = F4(
	function (shift, index, tail, tree) {
		var pos = $elm$core$Array$bitMask & (index >>> shift);
		if (_Utils_cmp(
			pos,
			$elm$core$Elm$JsArray$length(tree)) > -1) {
			if (shift === 5) {
				return A2(
					$elm$core$Elm$JsArray$push,
					$elm$core$Array$Leaf(tail),
					tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, $elm$core$Elm$JsArray$empty));
				return A2($elm$core$Elm$JsArray$push, newSub, tree);
			}
		} else {
			var value = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!value.$) {
				var subTree = value.a;
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, subTree));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4(
						$elm$core$Array$insertTailInTree,
						shift - $elm$core$Array$shiftStep,
						index,
						tail,
						$elm$core$Elm$JsArray$singleton(value)));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			}
		}
	});
var $elm$core$Array$unsafeReplaceTail = F2(
	function (newTail, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		var originalTailLen = $elm$core$Elm$JsArray$length(tail);
		var newTailLen = $elm$core$Elm$JsArray$length(newTail);
		var newArrayLen = len + (newTailLen - originalTailLen);
		if (_Utils_eq(newTailLen, $elm$core$Array$branchFactor)) {
			var overflow = _Utils_cmp(newArrayLen >>> $elm$core$Array$shiftStep, 1 << startShift) > 0;
			if (overflow) {
				var newShift = startShift + $elm$core$Array$shiftStep;
				var newTree = A4(
					$elm$core$Array$insertTailInTree,
					newShift,
					len,
					newTail,
					$elm$core$Elm$JsArray$singleton(
						$elm$core$Array$SubTree(tree)));
				return A4($elm$core$Array$Array_elm_builtin, newArrayLen, newShift, newTree, $elm$core$Elm$JsArray$empty);
			} else {
				return A4(
					$elm$core$Array$Array_elm_builtin,
					newArrayLen,
					startShift,
					A4($elm$core$Array$insertTailInTree, startShift, len, newTail, tree),
					$elm$core$Elm$JsArray$empty);
			}
		} else {
			return A4($elm$core$Array$Array_elm_builtin, newArrayLen, startShift, tree, newTail);
		}
	});
var $elm$core$Array$push = F2(
	function (a, array) {
		var tail = array.d;
		return A2(
			$elm$core$Array$unsafeReplaceTail,
			A2($elm$core$Elm$JsArray$push, a, tail),
			array);
	});
var $author$project$SDate$SDate$daysBeforeMonths = function (daysInMonths) {
	var fn = F2(
		function (days, _v1) {
			var sum = _v1.a;
			var arr = _v1.b;
			return _Utils_Tuple2(
				sum + days,
				A2($elm$core$Array$push, sum, arr));
		});
	var _v0 = A3(
		$elm$core$Array$foldl,
		fn,
		_Utils_Tuple2(0, $elm$core$Array$empty),
		daysInMonths);
	var sumsArray = _v0.b;
	return sumsArray;
};
var $author$project$SDate$SDate$daysBeforeMonthsInLeapYear = $author$project$SDate$SDate$daysBeforeMonths($author$project$SDate$SDate$daysInMonthsInLeapYear);
var $author$project$SDate$SDate$daysBeforeMonthsInStandardYear = $author$project$SDate$SDate$daysBeforeMonths($author$project$SDate$SDate$daysInMonthsInStandardYear);
var $author$project$SDate$SDate$daysBeforeMonthsInYear = function (year) {
	return $author$project$SDate$SDate$isLeapYear(year) ? $author$project$SDate$SDate$daysBeforeMonthsInLeapYear : $author$project$SDate$SDate$daysBeforeMonthsInStandardYear;
};
var $author$project$SDate$SDate$divisiblesInRange = F3(
	function (start, end, divisible) {
		var rem = $elm$core$Basics$remainderBy(divisible);
		var last = end - rem(end);
		var plus1Correction = (_Utils_cmp(last, end) < 0) ? 1 : 0;
		var first = start + rem(
			divisible - rem(start));
		return (_Utils_cmp(first, last) < 1) ? ((((last - first) / divisible) | 0) + plus1Correction) : 0;
	});
var $author$project$SDate$SDate$weekDay = function (sDay) {
	var _v0 = $author$project$SDate$SDate$dayToTuple(sDay);
	var year = _v0.a;
	var month = _v0.b;
	var day = _v0.c;
	var div100 = A3($author$project$SDate$SDate$divisiblesInRange, $author$project$SDate$SDate$minYear, year, 100);
	var div4 = A3($author$project$SDate$SDate$divisiblesInRange, $author$project$SDate$SDate$minYear, year, 4);
	var div400 = A3($author$project$SDate$SDate$divisiblesInRange, $author$project$SDate$SDate$minYear, year, 400);
	var monthDays = A2(
		$elm$core$Maybe$withDefault,
		0,
		A2(
			$elm$core$Array$get,
			month - 1,
			$author$project$SDate$SDate$daysBeforeMonthsInYear(year)));
	var wholeYears = year - $author$project$SDate$SDate$minYear;
	var yearDays = (((wholeYears * 365) + div4) - div100) + div400;
	var daysBetween = ((yearDays + monthDays) + day) - 1;
	return daysBetween % 7;
};
var $author$project$SDate$SDate$weeksInMonth = function (sMonth) {
	var tomorrow = function (wDay) {
		return (wDay + 1) % 7;
	};
	var monthBefore = $author$project$SDate$SDate$prevMonth(sMonth);
	var monthAfter = $author$project$SDate$SDate$nextMonth(sMonth);
	var lastDayOfMonth = A2(
		$author$project$SDate$SDate$SDay,
		sMonth,
		$author$project$SDate$SDate$daysInMonth(sMonth));
	var lastWeekDay = $author$project$SDate$SDate$weekDay(lastDayOfMonth);
	var lastDay = (lastWeekDay === 6) ? lastDayOfMonth : A2($author$project$SDate$SDate$SDay, monthAfter, 6 - lastWeekDay);
	var firstDayOfMonth = A2($author$project$SDate$SDate$SDay, sMonth, 1);
	var firstWeekDay = $author$project$SDate$SDate$weekDay(firstDayOfMonth);
	var firstDay = (!firstWeekDay) ? firstDayOfMonth : A2(
		$author$project$SDate$SDate$SDay,
		monthBefore,
		$author$project$SDate$SDate$daysInMonth(monthBefore) - (firstWeekDay - 1));
	var appendDay = F3(
		function (wDay, sDay, constructedWeeks) {
			appendDay:
			while (true) {
				var res = function () {
					if (!constructedWeeks.b) {
						return _List_fromArray(
							[
								_List_fromArray(
								[sDay])
							]);
					} else {
						var prevWeek = constructedWeeks.a;
						var rest = constructedWeeks.b;
						return (!wDay) ? A2(
							$elm$core$List$cons,
							_List_fromArray(
								[sDay]),
							constructedWeeks) : A2(
							$elm$core$List$cons,
							A2($elm$core$List$cons, sDay, prevWeek),
							rest);
					}
				}();
				if (_Utils_eq(sDay, lastDay)) {
					return res;
				} else {
					var $temp$wDay = tomorrow(wDay),
						$temp$sDay = $author$project$SDate$SDate$nextDay(sDay),
						$temp$constructedWeeks = res;
					wDay = $temp$wDay;
					sDay = $temp$sDay;
					constructedWeeks = $temp$constructedWeeks;
					continue appendDay;
				}
			}
		});
	var reversedAll = A3(appendDay, 0, firstDay, _List_Nil);
	var reversedWeeks = A2($elm$core$List$map, $elm$core$List$reverse, reversedAll);
	return $elm$core$List$reverse(reversedWeeks);
};
var $author$project$PollEditor$PollEditorView$viewDateCalendar = F3(
	function (state, pollData, viewConfig) {
		var weeks = $author$project$SDate$SDate$weeksInMonth(state.bS);
		var headerRow = $author$project$PollEditor$PollEditorView$viewDateCalendarHeaderRow(viewConfig.cQ);
		var controlsRow = A2($author$project$PollEditor$PollEditorView$viewDateCalendarControls, state, viewConfig);
		var cellFn = A3($author$project$PollEditor$PollEditorView$viewDateCalendarCell, state, pollData, viewConfig);
		var weekRow = function (days) {
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('calendar-row')
					]),
				A2($elm$core$List$map, cellFn, days));
		};
		var rows = A2($elm$core$List$map, weekRow, weeks);
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('calendar-table')
				]),
			A2(
				$elm$core$List$cons,
				controlsRow,
				A2($elm$core$List$cons, headerRow, rows)));
	});
var $author$project$PollEditor$PollEditorView$viewDeletePollButton = function (viewConfig) {
	var _v0 = viewConfig.cx;
	if (!_v0.$) {
		var msg = _v0.a;
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('poll-header-delete')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$button,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('delete-poll-button common-button common-input'),
							$elm$html$Html$Events$onClick(msg),
							$elm$html$Html$Attributes$title(viewConfig.cQ.h.cw)
						]),
					_List_fromArray(
						[
							$elm$html$Html$text('✗')
						]))
				]));
	} else {
		return A2($elm$html$Html$div, _List_Nil, _List_Nil);
	}
};
var $author$project$PollEditor$PollEditorModel$NoOp = {$: 14};
var $elm$core$Set$fromList = function (list) {
	return A3($elm$core$List$foldl, $elm$core$Set$insert, $elm$core$Set$empty, list);
};
var $elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3($elm$core$Dict$foldl, $elm$core$Dict$insert, t2, t1);
	});
var $elm$core$Set$union = F2(
	function (_v0, _v1) {
		var dict1 = _v0;
		var dict2 = _v1;
		return A2($elm$core$Dict$union, dict1, dict2);
	});
var $author$project$PollEditor$PollEditorView$viewPollDateItemTags = F3(
	function (state, pollData, viewConfig) {
		var tupleAsText = function (_v2) {
			var month = _v2.b;
			var date = _v2.c;
			return $elm$core$String$fromInt(date) + ('. ' + ($elm$core$String$fromInt(month) + '.'));
		};
		var tupleAsFullText = F2(
			function (_v1, hidden) {
				var year = _v1.a;
				var month = _v1.b;
				var date = _v1.c;
				return $elm$core$String$fromInt(date) + ('. ' + ($elm$core$String$fromInt(month) + ('. ' + ($elm$core$String$fromInt(year) + (hidden ? viewConfig.cQ.h.bE : '')))));
			});
		var allDays = $elm$core$Set$toList(
			A2(
				$elm$core$Set$union,
				pollData.af,
				$elm$core$Set$fromList(
					A2(
						$elm$core$List$map,
						function (i) {
							return $author$project$SDate$SDate$dayToTuple(i.a_);
						},
						pollData.aB))));
		var info = $elm$core$List$isEmpty(allDays) ? _List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('poll-date-tag-info')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(viewConfig.cQ.h.b4)
					]))
			]) : _List_Nil;
		var _v0 = $author$project$SDate$SDate$monthToTuple(state.bS);
		var shownYear = _v0.a;
		var shownMonth = _v0.b;
		var tupleToTag = function (tuple) {
			var year = tuple.a;
			var month = tuple.b;
			var originalItem = A2(
				$author$project$Common$ListUtils$findFirst,
				function (i) {
					return _Utils_eq(
						$elm$core$Maybe$Just(i.a_),
						$author$project$SDate$SDate$dayFromTuple(tuple));
				},
				pollData.aB);
			var isHidden = function (item) {
				return ((!item.aq) && A2(
					$elm$core$Set$member,
					$author$project$Data$DataModel$optionIdInt(item.az),
					pollData.ar)) || (item.aq && (!A2(
					$elm$core$Set$member,
					$author$project$Data$DataModel$optionIdInt(item.az),
					pollData.aZ)));
			};
			var hidden = A2(
				$elm$core$Maybe$withDefault,
				false,
				A2($elm$core$Maybe$map, isHidden, originalItem));
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('poll-date-tag'),
						$elm$html$Html$Events$onMouseEnter(
						viewConfig.cc(
							$author$project$PollEditor$PollEditorModel$SetHighlightedDay(
								$elm$core$Maybe$Just(tuple)))),
						$elm$html$Html$Events$onMouseLeave(
						viewConfig.cc(
							$author$project$PollEditor$PollEditorModel$SetHighlightedDay($elm$core$Maybe$Nothing)))
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class(
								'poll-date-tag-name' + (A2(
									$author$project$Common$CommonView$optClass,
									!_Utils_eq(
										_Utils_Tuple2(shownYear, shownMonth),
										_Utils_Tuple2(year, month)),
									'poll-date-tag-name-active') + (A2(
									$author$project$Common$CommonView$optClass,
									_Utils_eq(
										state.bG,
										$elm$core$Maybe$Just(tuple)),
									'poll-date-tag-name-highlighted') + A2($author$project$Common$CommonView$optClass, hidden, 'poll-date-tag-name-hidden')))),
								$elm$html$Html$Events$onClick(
								viewConfig.cc(
									A2(
										$elm$core$Maybe$withDefault,
										$author$project$PollEditor$PollEditorModel$NoOp,
										A2(
											$elm$core$Maybe$map,
											function (m) {
												return $author$project$PollEditor$PollEditorModel$SetCalendarMonth(m);
											},
											$author$project$SDate$SDate$monthFromTuple(
												_Utils_Tuple2(year, month)))))),
								$elm$html$Html$Attributes$title(
								A2(tupleAsFullText, tuple, hidden))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(
								tupleAsText(tuple))
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class(
								'poll-date-tag-delete' + A2($author$project$Common$CommonView$optClass, hidden, 'poll-date-tag-delete-hidden')),
								$elm$html$Html$Events$onClick(
								hidden ? viewConfig.cc(
									$author$project$PollEditor$PollEditorModel$AddDatePollItem(tuple)) : viewConfig.cc(
									$author$project$PollEditor$PollEditorModel$RemoveDatePollItem(tuple)))
							]),
						_List_fromArray(
							[
								hidden ? $elm$html$Html$text('👁') : $elm$html$Html$text('✗')
							]))
					]));
		};
		var tags = A2($elm$core$List$map, tupleToTag, allDays);
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('poll-date-tags')
				]),
			_Utils_ap(
				A2(
					$elm$core$List$cons,
					A2(
						$elm$html$Html$div,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(viewConfig.cQ.h.cb)
							])),
					tags),
				info));
	});
var $author$project$PollEditor$PollEditorView$viewPollDate = F4(
	function (model, state, pollData, viewConfig) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('poll poll-date')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('poll-header-row')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('poll-header-name')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(
									viewConfig.cQ.h.bu(viewConfig.ck + 1))
								])),
							$author$project$PollEditor$PollEditorView$viewDeletePollButton(viewConfig)
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('poll-body')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('poll-name-row')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$label,
									_List_Nil,
									_List_fromArray(
										[
											A2(
											$elm$html$Html$span,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('poll-name-label')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text(viewConfig.cQ.r.aH)
												])),
											A2(
											$elm$html$Html$input,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$type_('text'),
													$elm$html$Html$Attributes$class('common-input poll-name-input'),
													$elm$html$Html$Attributes$placeholder(viewConfig.cQ.h.cm),
													$elm$html$Html$Attributes$value(
													A2($elm$core$Maybe$withDefault, model.aC, model.be)),
													$elm$html$Html$Events$onInput(
													A2($elm$core$Basics$composeL, viewConfig.cc, $author$project$PollEditor$PollEditorModel$SetPollTitle))
												]),
											_List_Nil)
										])),
									A2(
									$elm$html$Html$label,
									_List_Nil,
									_List_fromArray(
										[
											A2(
											$elm$html$Html$span,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('poll-description-label')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text(viewConfig.cQ.r.aF)
												])),
											A2(
											$elm$html$Html$textarea,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('common-input poll-description-textarea'),
													$elm$html$Html$Attributes$placeholder(viewConfig.cQ.h.aG),
													$elm$html$Html$Attributes$value(
													A2($elm$core$Maybe$withDefault, model.aA, model.bd)),
													$elm$html$Html$Events$onInput(
													A2($elm$core$Basics$composeL, viewConfig.cc, $author$project$PollEditor$PollEditorModel$SetPollDescription))
												]),
											_List_Nil)
										]))
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('poll-instructions')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(viewConfig.cQ.h.b9)
								])),
							A3($author$project$PollEditor$PollEditorView$viewDateCalendar, state, pollData, viewConfig),
							A3($author$project$PollEditor$PollEditorView$viewPollDateItemTags, state, pollData, viewConfig)
						]))
				]));
	});
var $elm$html$Html$ol = _VirtualDom_node('ol');
var $author$project$PollEditor$PollEditorModel$AddGenericPollItem = {$: 3};
var $elm$html$Html$li = _VirtualDom_node('li');
var $author$project$PollEditor$PollEditorModel$HideGenericPollItem = function (a) {
	return {$: 6, a: a};
};
var $author$project$PollEditor$PollEditorModel$RenameGenericPollItem = F2(
	function (a, b) {
		return {$: 5, a: a, b: b};
	});
var $author$project$PollEditor$PollEditorModel$UnhideGenericPollItem = function (a) {
	return {$: 7, a: a};
};
var $author$project$PollEditor$PollEditorView$viewPollGenericItemExisting = F3(
	function (item, pollData, viewConfig) {
		var hidden = (item.aq && (!A2(
			$elm$core$Set$member,
			$author$project$Data$DataModel$optionIdInt(item.az),
			pollData.aZ))) || A2(
			$elm$core$Set$member,
			$author$project$Data$DataModel$optionIdInt(item.az),
			pollData.ar);
		return A2(
			$elm$html$Html$li,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('poll-option-generic')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$input,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$type_('text'),
							$elm$html$Html$Attributes$value(
							A2(
								$elm$core$Maybe$withDefault,
								item.a_,
								A2(
									$elm$core$Dict$get,
									$author$project$Data$DataModel$optionIdInt(item.az),
									pollData.cy))),
							$elm$html$Html$Attributes$placeholder(item.a_),
							$elm$html$Html$Attributes$class(
							'common-input poll-option-generic-input' + A2($author$project$Common$CommonView$optClass, hidden, 'poll-option-hidden')),
							$elm$html$Html$Events$onInput(
							A2(
								$elm$core$Basics$composeL,
								viewConfig.cc,
								$author$project$PollEditor$PollEditorModel$RenameGenericPollItem(item.az)))
						]),
					_List_Nil),
					$elm$html$Html$text(' '),
					A2(
					$elm$html$Html$button,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('common-button common-icon-button'),
							$elm$html$Html$Events$onClick(
							hidden ? viewConfig.cc(
								$author$project$PollEditor$PollEditorModel$UnhideGenericPollItem(item.az)) : viewConfig.cc(
								$author$project$PollEditor$PollEditorModel$HideGenericPollItem(item.az))),
							$elm$html$Html$Attributes$title(
							hidden ? viewConfig.cQ.h.cR : viewConfig.cQ.h.bF)
						]),
					_List_fromArray(
						[
							hidden ? $elm$html$Html$text('👁') : $elm$html$Html$text('✗')
						]))
				]));
	});
var $author$project$PollEditor$PollEditorModel$RemoveGenericPollItem = function (a) {
	return {$: 4, a: a};
};
var $author$project$PollEditor$PollEditorModel$SetNewGenericPollItem = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $author$project$PollEditor$PollEditorView$viewPollGenericItemNew = F4(
	function (itemNumber, itemValue, pollData, viewConfig) {
		return A2(
			$elm$html$Html$li,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('poll-option-generic')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$input,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$type_('text'),
							$elm$html$Html$Attributes$value(itemValue),
							$elm$html$Html$Attributes$class('common-input poll-option-generic-input'),
							$elm$html$Html$Events$onInput(
							A2(
								$elm$core$Basics$composeL,
								viewConfig.cc,
								$author$project$PollEditor$PollEditorModel$SetNewGenericPollItem(itemNumber)))
						]),
					_List_Nil),
					$elm$html$Html$text(' '),
					A2(
					$elm$html$Html$button,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('common-button common-icon-button'),
							$elm$html$Html$Events$onClick(
							viewConfig.cc(
								$author$project$PollEditor$PollEditorModel$RemoveGenericPollItem(itemNumber))),
							$elm$html$Html$Attributes$disabled(
							(!itemNumber) && ($elm$core$String$isEmpty(itemValue) && $elm$core$List$isEmpty(pollData.aB))),
							$elm$html$Html$Attributes$title(viewConfig.cQ.r.cv)
						]),
					_List_fromArray(
						[
							$elm$html$Html$text('✗')
						]))
				]));
	});
var $author$project$PollEditor$PollEditorView$viewPollGenericItems = F2(
	function (pollData, viewConfig) {
		var _new = A2(
			$elm$core$List$indexedMap,
			F2(
				function (itemNumber, item) {
					return A4($author$project$PollEditor$PollEditorView$viewPollGenericItemNew, itemNumber, item, pollData, viewConfig);
				}),
			pollData.af);
		var existing = A2(
			$elm$core$List$map,
			function (item) {
				return A3($author$project$PollEditor$PollEditorView$viewPollGenericItemExisting, item, pollData, viewConfig);
			},
			pollData.aB);
		var add = A2(
			$elm$html$Html$li,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('poll-option-generic')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$button,
					_List_fromArray(
						[
							$elm$html$Html$Events$onClick(
							viewConfig.cc($author$project$PollEditor$PollEditorModel$AddGenericPollItem)),
							$elm$html$Html$Attributes$class('common-button common-button-bigger colors-neutral common-add-icon')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(viewConfig.cQ.h.a1)
						]))
				]));
		return _Utils_ap(
			existing,
			_Utils_ap(
				_new,
				_List_fromArray(
					[add])));
	});
var $author$project$PollEditor$PollEditorView$viewPollGeneric = F3(
	function (model, pollData, viewConfig) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('poll poll-generic')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('poll-header-row')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('poll-header-name')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(
									viewConfig.cQ.h.bv(viewConfig.ck + 1))
								])),
							$author$project$PollEditor$PollEditorView$viewDeletePollButton(viewConfig)
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('poll-body')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('poll-name-row')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$label,
									_List_Nil,
									_List_fromArray(
										[
											A2(
											$elm$html$Html$span,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('poll-name-label')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text(viewConfig.cQ.r.aH)
												])),
											A2(
											$elm$html$Html$input,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$type_('text'),
													$elm$html$Html$Attributes$class('common-input poll-name-input'),
													$elm$html$Html$Attributes$placeholder(viewConfig.cQ.h.cn),
													$elm$html$Html$Attributes$value(
													A2($elm$core$Maybe$withDefault, model.aC, model.be)),
													$elm$html$Html$Events$onInput(
													A2($elm$core$Basics$composeL, viewConfig.cc, $author$project$PollEditor$PollEditorModel$SetPollTitle))
												]),
											_List_Nil)
										])),
									A2(
									$elm$html$Html$label,
									_List_Nil,
									_List_fromArray(
										[
											A2(
											$elm$html$Html$span,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('poll-description-label')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text(viewConfig.cQ.r.aF)
												])),
											A2(
											$elm$html$Html$textarea,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('common-input poll-description-textarea'),
													$elm$html$Html$Attributes$placeholder(viewConfig.cQ.h.aG),
													$elm$html$Html$Attributes$value(
													A2($elm$core$Maybe$withDefault, model.aA, model.bd)),
													$elm$html$Html$Events$onInput(
													A2($elm$core$Basics$composeL, viewConfig.cc, $author$project$PollEditor$PollEditorModel$SetPollDescription))
												]),
											_List_Nil)
										]))
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('poll-instructions')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(viewConfig.cQ.h.ca)
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('poll-options')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('poll-options-header')
										]),
									_List_fromArray(
										[
											$elm$html$Html$text(viewConfig.cQ.r.cl)
										])),
									A2(
									$elm$html$Html$ol,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('poll-options-list')
										]),
									A2($author$project$PollEditor$PollEditorView$viewPollGenericItems, pollData, viewConfig))
								]))
						]))
				]));
	});
var $author$project$PollEditor$PollEditorView$viewPoll = F2(
	function (model, viewConfig) {
		var _v0 = model.bt;
		if (_v0.$ === 1) {
			var genericDef = _v0.a;
			return A3($author$project$PollEditor$PollEditorView$viewPollGeneric, model, genericDef, viewConfig);
		} else {
			var state = _v0.a;
			var dateDef = _v0.b;
			return A4($author$project$PollEditor$PollEditorView$viewPollDate, model, state, dateDef, viewConfig);
		}
	});
var $author$project$Create$CreateView$viewEditing = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2($author$project$Translations$TranslationsView$translationsView, model.cQ, $author$project$Create$CreateModel$SetTranslation),
				A2(
				$elm$html$Html$h2,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text(model.cQ.n.bX)
					])),
				A2(
				$elm$html$Html$label,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('project-title-label')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(model.cQ.r.cs)
							])),
						A2(
						$elm$html$Html$input,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$type_('text'),
								$elm$html$Html$Attributes$class('project-title'),
								$elm$html$Html$Attributes$placeholder(model.cQ.r.ct),
								$elm$html$Html$Events$onInput($author$project$Create$CreateModel$SetTitle),
								$elm$html$Html$Attributes$value(model.S)
							]),
						_List_Nil)
					])),
				$author$project$Common$CommonView$viewBoxInfo(model.cQ.n.bJ),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('polls')
					]),
				A2(
					$elm$core$List$indexedMap,
					F2(
						function (i, p) {
							return A2(
								$author$project$PollEditor$PollEditorView$viewPoll,
								p,
								{
									cc: $author$project$Create$CreateModel$EditPoll(i),
									ck: i,
									cx: $elm$core$Maybe$Just(
										$author$project$Create$CreateModel$RemovePoll(i)),
									cP: model.cP,
									cQ: model.cQ
								});
						}),
					model.Z)),
				$elm$core$List$isEmpty(model.Z) ? $author$project$Create$CreateView$viewChooseFirstPoll(model.cQ) : A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('add-poll-line')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(model.cQ.n.a3),
						A2(
						$elm$html$Html$b,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(model.cQ.n.a2)
							])),
						$elm$html$Html$text(model.cQ.n.a4),
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nowrap')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$button,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('common-button common-button-bigger colors-add common-add-icon add-poll-button add-poll-generic'),
										$elm$html$Html$Events$onClick($author$project$Create$CreateModel$AddGenericPoll)
									]),
								_List_fromArray(
									[
										$elm$html$Html$text(model.cQ.r.aJ)
									])),
								$elm$html$Html$text(' '),
								A2(
								$elm$html$Html$button,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('common-button common-button-bigger colors-add common-add-icon add-poll-button add-poll-date'),
										$elm$html$Html$Events$onClick($author$project$Create$CreateModel$AddDatePoll)
									]),
								_List_fromArray(
									[
										$elm$html$Html$text(model.cQ.r.aI)
									]))
							]))
					])),
				function () {
				var _v0 = model.bm;
				if (_v0.$ === 1) {
					return A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('submit-row')
							]),
						_List_fromArray(
							[
								$author$project$Create$CreateView$submitButton(model)
							]));
				} else {
					var projectKey = _v0.a.cr;
					var secretKey = _v0.a.cI;
					return A2(
						$elm$html$Html$div,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text('created'),
								$elm$html$Html$text(projectKey),
								$elm$html$Html$text(secretKey)
							]));
				}
			}()
			]));
};
var $author$project$Create$CreateView$view = function (model) {
	var _v0 = model.bm;
	if (_v0.$ === 1) {
		return $author$project$Create$CreateView$viewEditing(model);
	} else {
		var projectInfo = _v0.a;
		return A2($author$project$Create$CreateView$viewCreated, projectInfo, model);
	}
};
var $author$project$CreatePage$main = $elm$browser$Browser$element(
	{bL: $author$project$Create$CreateUpdate$init, cK: $author$project$Create$CreateUpdate$subscriptions, cT: $author$project$Create$CreateUpdate$update, cU: $author$project$Create$CreateView$view});
_Platform_export({'CreatePage':{'init':$author$project$CreatePage$main($elm$json$Json$Decode$value)(0)}});}(this));
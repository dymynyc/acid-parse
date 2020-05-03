var parse = require('acidlisp/require')(__dirname)('../acid')
var hexpp = require('hexpp')
var tape = require('tape')

var mem = Buffer.from(parse.memory.buffer)
var m = require('acidlisp/require')(__dirname, mem)
  ('acid-memory', {eval: true})

function get_head_t (p) {
  return mem.readUInt32LE(p)
}
function get_head (p) {
  return mem.readUInt32LE(p+4)
}
function get_tail_t (p) {
  return mem.readUInt32LE(p+8)
}
function get_tail (p) {
  return mem.readUInt32LE(p+12)
}

function get_string (s) {
  var length = mem.readUInt32LE(s)
  return mem.slice(s+4, s+4+length).toString()
}

function toString(l) {
  var s = '('
  while(l) {
    var value
    if(get_head_t(l) == 0)
      value = 'nil'
    else if(get_head_t(l) == 1) // list
      value = toString(get_head(l))
    else if(get_head_t(l) == 2) //number
      value = get_head(l)|0
    else if(get_head_t(l) == 3)
      value = '"'+get_string(get_head(l))+'"'
    else if(get_head_t(l) == 4)
      value = get_string(get_head(l))
    else
      throw new Error('unknown type')
//    console.error(value, get_head_t(l), l)
    s+=value + ' '
    l = get_tail(l)
  }
  return s.trim() +')'
}


function makeTest(str, test, expected) {
  tape(str +' -> '+expected, function (t) {
    var input = Buffer.from(str)

    var ptr = m.alloc(input.length+4)
    mem.writeUInt32LE(input.length+4, ptr)
    input.copy(mem, ptr+4)
    var v = parse[test](ptr, 0)
    t.equal(toString(v), expected)
    t.end()
  })

}

  makeTest("123",   "int32",   '(123)')
  makeTest("10000", "int32", '(10000)')
  makeTest("0",     'int32',     '(0)')
  makeTest("-1",    'int32',    '(-1)')
  makeTest("1",     'int32',     '(1)')

  makeTest("(foo bar baz)",    'parse', '((foo bar baz))')
  makeTest("(foo (bar baz))",  'parse', '((foo (bar baz)))')
  makeTest("((bar baz))",      'parse', '(((bar baz)))')
  makeTest("(x nil y)",        'parse', '((x nil y))')
  makeTest("((((((x))))))",    'parse', '(((((((x)))))))')
  makeTest("(x (y))",          'parse', '((x (y)))')
  makeTest("((x) y)",          'parse', '(((x) y))')
  makeTest("(x (y) z)",        'parse', '((x (y) z))')

tape('test symbols are equal', function (t) {
  var input = Buffer.from('(foo foo)')
  var ptr = m.alloc(input.length+4)
  mem.writeUInt32LE(input.length+4, ptr)
  input.copy(mem, ptr+4)
  var v = get_head(parse.parse(ptr, 0))
  t.equal(get_head(v), get_head(get_tail(v)))
  t.notEqual(v, get_tail(v)) //make sure we arn't fooling ourselves
  t.equal(get_string(get_head(v)), get_string(get_head(get_tail(v))))
  t.end()
})

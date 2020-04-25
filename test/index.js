var parse = require('acidlisp/require')(__dirname)('./acid/hello-world')
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
      value = get_head(l)
    else {
      value = '"'+get_string(get_head(l))+'"'
    }
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
  makeTest(
    "(AAABBCCDEfABCA BC    DEF)", 'test',
    '("AAABBCC" "DEf" "ABCA" "BC" "DEF")')
//
  makeTest("123", "number", '("123")')
  makeTest("10000", "number", '("10000")')
  makeTest("0", 'number', '("0")')
  makeTest("-1", 'number', '("-1")')
  makeTest("1", 'number', '("1")')
//
  makeTest("(foo bar baz)", 'recurse', '(("foo" "bar" "baz"))')
  makeTest("(foo (bar baz))", 'recurse', '(("foo" ("bar" "baz")))')
  makeTest("((bar baz))", 'recurse', '((("bar" "baz")))')
  makeTest("(x nil y)", 'recurse', '(("x" nil "y"))')
  makeTest("((((((x))))))", 'recurse', '((((((("x")))))))')
  makeTest("(x (y))", 'recurse', '(("x" ("y")))')
  makeTest("((x) y)", 'recurse', '((("x") "y"))')
  makeTest("(x (y) z)", 'recurse', '(("x" ("y") "z"))')

tape('what should empty list look like?', function (t) {
  console.error(toString(parse.fake()))
  t.end()
})

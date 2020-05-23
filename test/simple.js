var parse = require('acidlisp/require')(__dirname)('../simple')
var hexpp = require('hexpp')
var tape = require('tape')

var mem = Buffer.from(parse.memory.buffer)
var m = require('acidlisp/require')(__dirname, mem)
  ('acid-memory', {eval: true})

function makeTest(str, test, expected) {
  tape(str +' -> '+expected, function (t) {
    var input = Buffer.from(str)

    var ptr = m.alloc(input.length+4)
    mem.writeUInt32LE(input.length+4, ptr)
    input.copy(mem, ptr+4)
    var v = parse[test](ptr, 0, input.length, 0)
    t.equal(v, expected)
    t.end()
  })

}

makeTest('foo', 'foo', 3)
makeTest('fo', 'foo', -1)
makeTest('fo', 'bar', -1)
makeTest('barbar', 'bar', 3)
makeTest('foo', 'foo_bar', 3)
makeTest('foofoo', 'foofoo', 6)
makeTest('foobar', 'foobar', 6)
makeTest('foo', 'foo_bar', 3)
makeTest('foobar', 'x_star', 0)
makeTest('xxx.', 'x_star', 3)
makeTest('xxxxxxx.', 'x_star', 7)
makeTest('foobar', 'fb_star', 6)
makeTest('foofoobarbar', 'fb_star', 12)
makeTest('fx', 'fb_star', 0)

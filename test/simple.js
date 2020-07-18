var parse = require('acidlisp/require')(__dirname, null, {
  sys: {
    log_i: function (i){
      console.log('log_i', i)
      return i
    },
    log: function (s) {
      console.log('log', s)
//      var l = mem.readUInt32LE(s)
//      if(l < 20)
//        console.log(mem.slice(4+s, 4+s+l).toString())
//      else console.log(l)
      return s
    },
    log2: function (i, s, e) {
      console.log('log2', i, s, e)
      console.log(mem.slice(4+i+s, 4+i+e).toString())
      return i
    },

  }
})('../simple')
var hexpp = require('hexpp')
var tape  = require('tape')

var mem   = Buffer.from(parse.memory.buffer)
var l     = require('./lists')(mem)
var m     = require('acidlisp/require')(__dirname, mem)
  ('acid-memory', {eval: true})

function makeTest(str, test, expected) {
  tape(str +' -> '+expected, function (t) {
    var input = Buffer.from(str)

    var ptr = m.alloc(input.length+4)
    mem.writeUInt32LE(input.length, ptr)
    input.copy(mem, ptr+4)
    var g = parse.init()
    var v = parse[test](ptr, 0, input.length, g)
    t.equal(v, expected)
    console.log('******')
    console.log(l.toString(l.get_head(g)))
    console.log('******')
//    console.log(l.get_tail(g))
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
makeTest('abcd', 'abc', 3, '')

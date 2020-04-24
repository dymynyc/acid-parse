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
    else if(get_head_t(l) == 1)
      value = toString(get_head(l))
    else if(get_head_t(l) == 2)
      value = get_head(l)
    else {
      value = '"'+get_string(get_head(l))+'"'
    }
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


//  console.log(hexpp(mem.slice(0, 1024)))
//
//  console.log("input:"+input.toString())
//  console.log('matched', v, {input: input.length})
//  console.log('output:', toString(v))
//  console.log(hexpp(mem.slice(0, 1024)))

//})

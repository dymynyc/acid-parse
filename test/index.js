var parse = require('acidlisp/require')(__dirname)('./acid/hello-world')
var hexpp = require('hexpp')

var mem = Buffer.from(parse.memory.buffer)

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
  console.log(s, length, mem.slice(s, s+4))
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
    console.log('()', get_head(l), get_tail(l), value)
  
    s+=value + ' '
//      throw new Error('type not supported')
    l = get_tail(l)
  }
  return s.trim() +')'
}


var input = Buffer.from("AA A  A   A")
console.log(parse)

var ptr = 10000

input.copy(mem, ptr+4)
mem.writeUInt32LE(input.length, ptr)

var v = parse.test(ptr, 0)
console.log(v, input.length)
console.log(toString(v))

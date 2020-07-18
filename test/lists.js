module.exports = function (mem) {
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
        value = get_string(get_head(l)) //string
      else
        throw new Error('unknown type')
      console.error(value, get_head_t(l), l)
      s+=value + '  '
      if(l === get_tail(l)) throw new Error('cyclic list')
      l = get_tail(l)
    }
    return s.trim() +')'
  }

  return {
    get_head, get_tail, toString, get_string
  }
}

var a = require('acidlisp/require')(__dirname)('../append')
//var lists = require('acidlisp/require')(__dirname)('acid-lists')

var hexpp = require('hexpp')
var tape = require('tape')

var mem = Buffer.from(a.memory.buffer)
var {get_head, get_tail, toString}   = require('./lists')(mem)
var m   = require('acidlisp/require')(__dirname, mem)
  ('acid-memory', {eval: true})

tape('simple', function (t) {
  var g = a.init()
  t.equal(get_head(g), 0)
  t.equal(get_tail(g), 0)
  var v = a.append(g, 2, 20)
  t.notEqual(get_head(g), 0)
  console.log("g", toString(g))
  console.log("head", get_head(g))
  t.equal(get_head(get_head(g)), 20)
  t.equal(get_head(get_tail(g)), 20)
  t.equal(get_tail(g), get_head(g))
  var v = a.append(g, 2, 30)
  t.notEqual(get_tail(g), get_head(g), 'after second item, head should not equal tail')
  console.log('tail', v)
  t.equal(get_head(v), 30)
  t.equal(get_tail(v), 0)
  t.equal(get_head(get_head(g)), 20)
  t.equal(get_head(get_tail(get_head(g))), 30)
  t.equal(get_head(get_tail(g)), 30)
  t.equal(get_tail(get_tail(g)), 0)
  console.log(toString(g))
  //t.equal(get_head(get_tail(g)), 30)
//  console.log("g", toString(g))
  console.log(a.append(g, 2, 40))
//  t.equal(get_head(get_tail(g)), 40)
//  t.notEqual(get_head(g), 0)
 console.log(a.append(g, 2, 60))
//  t.notEqual(get_head(g), 

  console.log("g", toString(g))
  t.equal(toString(get_head(g)), '(20 30 40 60)')
//  console.log("v", toString(v))
  t.end()
})

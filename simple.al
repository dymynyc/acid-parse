(module
  (def p (import "./"))

  (export foo (p.Match "foo"))
  (export bar (p.Match "bar"))

  (def foo_bar (p.Or (p.Match "foo") (p.Match "bar")))
  (export foofoo (p.And (p.Match "foo") (p.Match "foo")))
  (export foobar (p.And (p.Match "foo") (p.Match "bar")))
  (export foo_bar foo_bar)
  (export x_star (p.Many (p.Match "x")))
  (export fb_star (p.Many foo_bar))

)

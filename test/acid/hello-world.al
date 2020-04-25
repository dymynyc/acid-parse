(module
  (def P (import "acid-parse"))
  (def s (import "acid-strings"))
  (def l (import "acid-lists"))
  (def i (import "acid-int_to_string"))

  (def And P.And)
  (def Match P.Match)
  (def Or P.Or)
  (def Many P.Many)
  (def Text P.Text)
  (def Group P.Group)
  (def Map P.Map)
  (def Range P.Range)
  (def Parser P.Parser)

  ;;a single char of any whitespace
  (def ws (mac ()
     &(Or (Match " ")
      (Or (Match "\t")
      (Or (Match "\r")
          (Match "\n") )))
  ))

  ;; one or more repeated whitespace.
  (def man_ws (mac () &(More (ws) ) ))

  ;; zero or  more repeated whitespace
  (def opt_ws (mac () &(Many (ws)) ))

  (def zero_to_nine (mac () &(Range 48  57) ))
  (def one_to_nine  (mac () &(Range 49  57) ))
  (def a_to_z       (mac () &(Range 97 122) ))

  (def Symbol (mac () &(Text
    (And (a_to_z) (Many (Or (a_to_z) (zero_to_nine))))
  )))

  [def Integer (mac ()
    &{Map
      {Or (Match "0")
        (And (Maybe (Match "-"))
          (And (one_to_nine) (Many (zero_to_nine))) )
      } 2 [block
        (log (i.encode start))
        (log "\n")
        (i.decode input start (add start matched))
      ]}
  )]

  (export number {Parser (Integer)})

  (def Surround (mac (op content cl)
    &{And (Match $op) (And $content (Match $cl))}
  ))

  (def Join (mac (content separator)
    &(And $content (Many (And $separator $content)))
  ))

  ;; this is a hack. currently, GROUP_GLOBAL is stored
  ;; in data section, with pointer inlined. we couldn't
  ;; reassign it, but we can mutate it.
  ;; this would still work if we had globals, without
  ;; updating data section. but it that case we can remove the cons.

  (def GROUP_GLOBAL (l.create 0 0 0 0))
  (def Call (mac (fn) &{block
    (def m ($fn input start group))
    ;;(if (neq -1 m) -1
    (set group (l.get_head GROUP_GLOBAL))
    (l.set_head GROUP_GLOBAL 0 0)
    m
  }))

  (def Nil (mac () &(Map (Match "nil") 0 0) ))

  (def Value (mac ()
    &(Or (Nil) (Or (Symbol) (Integer)))
  ))

  (def _recurse (fun _recurse (input start group) {block
    (def m (Group (Surround "("
      (Maybe (Join (Or (Value) (Call _recurse)) (man_ws)))
      ")" )))
    (l.set_head GROUP_GLOBAL 1 group)  
    m
  }))

  (def recurse (fun recurse (input start) (block
    (def group (def _g (l.create 0 0 0 0)))
    (if (neq -1 (_recurse input start group)) (l.get_tail _g) 0)
  )))

  (export recurse recurse)

  (export test (Parser
    [And (Match "(") [And (Many (Or
      (Text (More
        (Or (Match "A") (Or (Match "B") (Match "C")))
      ))
      (Or
        [Text
          (And (Match "DE")
          [Or  (Match "F")
               (Match "f")] )]
          (man_ws))
    )) (Match ")") ]];;)
    ))
)

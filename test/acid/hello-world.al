(module
  (def P (import "acid-parse"))
  (def s (import "acid-strings"))
  (def l (import "acid-lists"))

  (def And P.And)
  (def Match P.Match)
  (def Or P.Or)
  (def Many P.Many)
  (def Text P.Text)
  (def Group P.Group)

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

  (def Parser (mac (pattern) (block
      &(fun (input start) {block
        (def _G (def $(quote group) (l.create 0 0 0 0)))
        (def m $pattern)
        (if (neq -1 m) (l.get_tail _G) 0)
      })
    )
  ))

  (def Range (mac (lo hi) &{block
    (def c (s.at input start))
    (if (and (gte c $lo) (lte c $hi)) 1 -1)
  }))

  (def zero_to_nine (mac () &(Range 48  57) ))
  (def one_to_nine  (mac () &(Range 49  57) ))
  (def a_to_z       (mac () &(Range 97 122) ))

  (def Symbol (mac () &(Text
    (And (a_to_z) (Many (Or (a_to_z) (zero_to_nine))))
  )))

  [def Integer (mac ()
    &{Text
      {Or (Match "0")
        (And (Maybe (Match "-"))
          (And (one_to_nine) (Many (zero_to_nine))) )
     }}
  )]

  (export number {Parser (Integer)})

  (def Surround (mac (op content cl)
    &{And (Match $op) (And $content (Match $cl))}
  ))

  (def Join (mac (content separator)
    &(And $content (Many (And $separator $content)))
  ))

  ;;simplest, is the function returns a (cons matched group)
  ;;could use a global to store the group in but then

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

  [def Map (mac (rule type value) &{block
    (def _start start)
   (if (neq -1 (def text_m $rule))
      ;; if the rule matched, copy the text into group list
      (if (l.get_head group)
        (block
          (def v $value)
          (set group
            (l.set_tail group 1 (l.create $type v 0 0)))
          (l.set_head group $type v)
        )
      )
    )
    text_m
  })]


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

;;  (export test (fun (input start) {block
;;    (def _group (def group (l.create 0 0 0 0)))
;;    (def m 
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
;;    (if (neq -1 m) _group 0)
;;  }))

  (export fake (fun ()
    (l.create 2 "foo"
      1 (l.create 1 (l.create 0 0 0 0)
        1 (l.create 2 "bar" 0 0) ))
  ))
)

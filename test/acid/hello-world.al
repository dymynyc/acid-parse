(module
  (def P (import "acid-parse"))
  (def s (import "acid-strings"))
  (def l (import "acid-lists"))

  (def And P.And)
  (def Match P.Match)
  (def Or P.Or)
  (def Many P.Many)
  (def Text P.Text)

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
        (if (neq -1 m) _G 0)
      })
    )
  ))

;;  (export parens (fun (input start) {block
;;    (def _group (def group (l.create 0 0 0 0)))
;;    (def m
;;  })

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

  [def Number (mac ()
    &(Text
      (Or (Match "0") (And (one_to_nine) (Many (zero_to_nine)) ))) )]

  (export number {Parser (Number)})

  (def Surround (mac (op content cl)
    &{And (Match $op) (And $content (Match $cl))}
  ))

  (def Join (mac (content separator)
    &(And $content (Many (And $separator $content)))
  ))

  (export recurse (fun (input start) (block
    (def group (def _g (l.create 0 0 0 0)))
    (def m (Surround "(" (Maybe (Join (Symbol) (man_ws))) ")"))
    (if (neq -1 m) _g 0)
  )))

  (export test (fun (input start) {block
;;  (export test  {Parser
    (def _group (def group (l.create 0 0 0 0)))
    (def m 
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
      )) (Match ")") ]])
    (if (neq -1 m) _group 0)
  }))
)

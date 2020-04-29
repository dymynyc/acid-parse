(module
  (def P (import "."))
  (def l (import "acid-lists"))
  (def i (import "acid-ints"))

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
  (def A_to_Z       (mac () &(Range 65  90) ))
  
  (def letters (mac () &(Or (a_to_z) (Or (A_to_Z) (Match "_")) )))

  (def Symbol (mac () &(Text
    (And (letters) (Many (Or (letters) (zero_to_nine))))
  )))

  [def Integer (mac ()
    &{Map
      {Or (Match "0")
        (And (Maybe (Match "-"))
          (And (one_to_nine) (Many (zero_to_nine))) )
      } 2 [block
        (i.decode input start (add start matched))
      ]}
  )]

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

  (def parse (fun (input start) (block
    (def group (def _g (l.create 0 0 0 0)))
    (if (neq -1 (_recurse input start group)) (l.get_tail _g) 0)
  )))


  ;; macros

;;TODO: enable exporting macros and functions to be compiled
;;      at the same time

;;  (export ws ws)
;;  (export man_ws man_ws)
;;  (export opt_ws opt_ws)
;;  (export zero_to_nine zero_to_nine)
;;  (export one_to_nine one_to_nine)
;;  (export a_to_z a_to_z)
;;  (export Nil Nil)
;;  (export Value Value)
;;  (export Integer Integer)
;;  (export Surround Surround)
;;  (export Join Join)

  ;; functions
  (export int32 {Parser (Integer)})
  (export parse parse)
)

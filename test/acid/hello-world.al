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

     &(Or (Match " ") (Match "X"))
;;     &(Or (Match " ")
;;      (Or (Match "\t")
 ;;     (Or (Match "\r")
  ;;        (Match "\n") )))
  ))

  ;; one or more repeated whitespace.
  (def man_ws (mac () &(More (Match " ") ) ))

  ;; zero or  more repeated whitespace
  (def opt_ws (mac () &(Many (ws)) ))

  (export test (fun (input start) {block
    (def group (l.create 0 0 0 0))
    (def _group group)
    (if (eq -1
      (Many (Or (More (Match " ")) (Text
        (Match "A")
;;        (Or (Match "A")
;;        (Or (Match "B")
;;            (Match "C")))
      )))
) 0 _group)
  }))
)

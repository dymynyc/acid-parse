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

    (def _group (def group (l.create 0 0 0 0)))
    (def m [And (Match "(") [And (Many (Or
      (Text (More
        (Or (Match "A") (Or (Match "B") (Match "C")))
      ))
      (Or
        [Text (And (Match "DE")
          [Or (Match "F") (Match "f")])]

        (More (Match " ")))
    )) (Match ")") ]])
;;    (if (neq m 6) (log "FAIL 1") 0)
;;    (if (neq start 3) (log "FAIL 2") 0)
    (if (neq -1 m) _group 0)
  }))
)

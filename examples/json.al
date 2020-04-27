(module
  (def P (import "acid-parse"))

  (def And P.And)
  (def Match P.Match)
  (def Range P.Range)
  (def Or P.Or)
  (def Many P.Many)
  (def Text P.Text)

  (def String (mac ()
     &(And (Match "\"")
      (And (Text (Many (Or
              (Match " ")
              (Range 35 126) )))
           (Match "\"") ))
  ))

  ;;it's not a recursive object yet...

  (def Object (mac ()
    &(And (Match "{")
     (And (Join
       (And (String)
       (And (Match ":")
       (And (String) )))
        ",")
          (Match "}") ))
  ))



)

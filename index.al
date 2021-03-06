(module
  (def strings (import "acid-strings"))
  (def a (import "./append"))
;;  (def lists   (import "acid-lists"))


  (def log_i (system "sys" "log_i" (i)))
  (def log (system "sys" "log" (string)))
  (def log2 (system "sys" "log2" (i s e)))
  ;; matches an exact string either completely or not at all

  (def Match (fun (str) (block
    (def l (strings.length str))
    (fun (input start end groups)
      (if (lt (sub end start) l) -1 ;;check enough length remaining
        (if (strings.equal_at input start str 0 l) (strings.length str) -1)
      )
    ))
  ))

  ;; Range - matches between high and low ascii character values

  (def Range (fun (lo hi) (fun (input start end groups)
    {block
      (def c (strings.at input start))
      (if (and (gte c lo) (lte c hi)) 1 -1)
    }
  )))

  ;; Or - matches a or b (fails if both do not match)

  (def Or (fun (f g) (fun (i s e group)
    (if (neq -1 (def m (f i s e group))) m
    (if (neq -1 (def m (g i s e group))) m
                                                  -1))
  )))

  ;; And - matches a then b (fails if a fails, or a works and b fails)

  (def And (fun (f g) (fun (input start end group)
    (if (eq -1 (def m (f input         start end group))) -1
    (if (eq -1 (def n (g input (add m start) end group))) -1
                                                          (add m n)))
  )))

  ;; Many - matches 0 or more a. never fails, just matches zero times.
  ;;        can infinite loop if another zero matching rule is inside it.
  ;;        or within or (Or (Maybe x) y) (Maybe x) will always match
  [def Many (fun (f) (fun (i s e g)
    ((fun R (sum m)
      (if (neq -1 m) (R (add m sum) (f i (add m sum s) e g)) sum)
    ) 0 0)
  ))]

  ;; More - matches one or more times. fails if the first match fails.

  (def More [fun (a) (And a (Many a))])

  ;; Maybe - matches zero or one times. never fails.

  (def Empty (fun (i s e g) 0))

  (def Maybe [fun (a) (Or a Empty)])

  ;; Map - transforms a match into a value.
  ;;       takes a rule, a type, and code
  ;;       - type is the sort of list pointer
  ;;         0 - nil, 1 - list, 2 - number, 3 - string
  ;;       - code is is an expression that returns the value.
  ;;         it can see variables input start matched
  ;;         (see Text, below for an example)

  (def Map (fun (matcher type mapper) (fun (i s e g)
    (if (neq -1 (def m (matcher i s e g)))
      (block (a.append g type (mapper i s (add m s))) m)
      -1
    )
  )))

  [def Text (fun (matcher)
    (Map matcher 3 (fun (i s e) (block
      (log2 i s e)
      (log (strings.slice i s e))
    )))
  )]

  [def Group (fun (matcher) (fun (i s e g)
    (block
      (def g2 (a.init))
;;      (def _head (l.get_head g))
;;      (def _tail (l.get_tail g))
;;      (l.set_head g 0 0)
;;      (l.set_tail g 0 0)
      (if (neq -1 (def m (matcher i s e g2)))
        (block
;;          (def v (l.get_head g))
;;          (l.set_head g _h_t _head)
;;          (l.set_tail g 1 _tail)
          (a.append g 1 (l.get_head g2))
          m
        )
        (block
          
;;          (l.set_head g _h_t _head)
;;          (l.set_tail g 1 _tail)
          ;;and free the any matched items
          -1
        )
      )
    )
  ))]



  ;; Text - captures text around a match.

  ;;        note that this just uses the Map rule, with string.slice

  ;; Group - captures a list of items.
  ;;         any captures inside of this rule are added,
  ;;         including other groups

  ;; Parser - takes a rule and returns a parse function, ready for export

  (export Match Match)
  (export And And)
  (export Or Or)
  (export Many Many)
  (export More More)
  (export Maybe Maybe)
  (export Empty Empty)

;;  (export Group Group)
  (export Text Text)
;;  (export Parser Parser)
;;  (export Map Map)
;;  (export Range Range)
)

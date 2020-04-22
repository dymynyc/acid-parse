(module
  (def strings (import "acid-strings"))
  (def lists   (import "acid-lists"))


  (def _match (mac R (str i) (block
    (def len (strings.length str))
    (if (eq i (sub len 1))
      &(if (eq (strings.at input (add start $i)) $(strings.at str i)) len -1)
      &(if (eq (strings.at input (add start $i)) $(strings.at str i))
        (R $str $(add 1 i)) -1)
    )
  )))

  [def append (mac (p type value)
    &(if (lists.get_head $p)
      (lists.set_tail $p (lists.create $type $value 0 0))
      (block (lists.set_head $p $type $value) $p)
    ))]

  [def Group (mac (rule) &{block
    (def _startY start) ;;XX unused?
    ;; append an empty list to group
    (set group (append (def _group group) 1 (lists.create 0 0 0 0)))
    (if (neq -1 (def m $rule))
        ;; if the rule matched, keep the group we made
        (set group (lists.get_tail _group))
        ;; else, revert to the old group.
        ;; TODO: free memory or implement GC
        (block
          (lists.set_tail _group 0 0) ;;discard.
          (set group _group)
        )
    )
    m
  })]

  [def Text (mac (rule) &{block
    (def _start start)
    (if (neq -1 (def text_m $rule))
      ;; if the rule matched, copy the text into group list
      (block
        (def value (strings.slice input _start (add _start text_m)))
        (if (lists.get_head group)
          (set group
            (lists.set_tail group 1 (lists.create 3 value 0 0)))
          (lists.set_head group 3 value)
        )
      )
    )
    text_m
  })]

  (def Match (mac (str) (list _match str 0)))

  (def Or (mac (a b)
    &(if (neq -1 (def or_m $a)) or_m (if (neq -1 (def or_m $b)) or_m -1))
  ))

  (def And [mac (a b)
    &{block
      (def and_start start) ;;_start will be made hygenic
      (if
        (neq -1 (def and_m1 $a))
        [block
          (set start (add and_start and_m1))
          (if
            (neq -1 (def and_m2 $b))
            (add and_m1 and_m2) ;;<-- return  value if both match
            (block (set start and_start) -1)
          )
        ]
        (block (set start and_start) -1)
      )
    }])

  (def Many [mac (a) &{block
    (def many_m2 0)
    (loop (neq -1 (def many_m $a))
      (block
        (set start (add start many_m))
        (set many_m2 (add many_m2 many_m))
      )
    )
    many_m2
  }])

  (def More [mac (a) &(And $a (Many $a))])

  (def Maybe [mac (a) &(Or $a 0)])

  (export Match Match)
  (export And And)
  (export Or Or)
  (export Many Many)
  (export More More)
  (export Maybe Maybe)
  (export Group Group)
  (export Text Text)

;;  (export (fun (input start group) {block
;;    (And
;;      (Text (Match "HELLO"))
;;      (Text (Match "THERE"))
;;    )
;;  }))
)

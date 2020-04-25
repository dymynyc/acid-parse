(module
  (def strings (import "acid-strings"))
  (def lists   (import "acid-lists"))
;;  (def i2s
;;               (import "acid-int_to_string"))


  (def _match (mac R (str i) (block
    (def len (strings.length str))
    (if (eq i (sub len 1))
      &(if (eq (strings.at input (add start $i)) $(strings.at str i)) $len -1)
      &(if
        (eq (strings.at input (add start $i)) $(strings.at str i))
        (R $str $(add 1 i))
        -1)
    )
  )))

;;  [def append (fun (pX type v)
;;    (if (lists.get_head pX)
;;      (lists.set_tail pX (lists.create type v 0 0))
;;      (block (lists.set_head pX type v) pX)
;;    ))]

  [def Group (mac (rule) &{block
    (def _startY start) ;;XX unused?
    ;; append an empty list to group

    (lists.set_tail group
      1 (def parent (lists.create 1 (def new_group (lists.create 0 0 0 0)) 0 0)) )

    (set group new_group)
    (if (neq -1 (def m $rule))
      ;; point `group` var back to list where our group started.
      ;; it should still have an empty tail
      (block
        (lists.set_head parent 1 (lists.get_tail (lists.get_head parent)))
        (set group parent)
      )
      ;; else, revert to the old group.
      ;; TODO: free memory or implement GC
      (block
        ;; oh, need to undo the head pointer?
        (lists.set_tail (lists.get_head parent) 0 0) ;;discard, but leave an empty group
        (set group parent)
      )
    )
    m
  })]

;;  (def log_int (mac (label int) &{block
;;    (log $label)
;;    (log (i2s.int_to_string $int))
;;    (log "\n")
;;  }))

  [def Text (mac (rule) &{block
    (def _start start)
    (if (neq -1 (def text_m $rule))
      ;; if the rule matched, copy the text into group list
      (set group
        (lists.set_tail group
          1 (lists.create
            3 (strings.slice input _start (add _start text_m))
            0 0) ))
    )
    text_m
  })]

  (def Match (mac (str) (list _match str 0)))

;;  (def Match (mac (str) (block
;;    (def len (strings.length str))
;;    &(if (strings.equal_at input start $str 0 $len) $len -1) )))

  (def Or (mac (a b)
    &(if (neq -1 (def or_m $a)) or_m (if (neq -1 (def or_m $b)) or_m -1))
  ))

;;  (def Or (mac (a b) &(block
;;    (def or_start start)
;;    (if (neq -1 (def or_m $a))
;;      or_m
;;      (block
;;        (set start or_start)
;;        (if (neq -1 (def or_m $b)) or_m -1) ))
;;  )))

  (def And [mac (a b)
    &{block
      (def and_start start) ;;_start will be made hygenic
      (if
        (neq -1 (def and_m1 $a))
        [block
          (set start (add and_start and_m1))
          (if
            (neq -1 (def and_m2 $b))
            (block
              (def and_total (add and_m1 and_m2))
              and_total
            )
               ;;<-- return  value if both match
            (block (set start and_start) -1)
          )
        ]
        (block (set start and_start) -1)
      )
    }])

  (def Many [mac (a) &{block
    (def many_m (def many_m2 0))
    (def _start start)
    (loop (neq -1 (def many_m $a))
      (block
        (set start (set _start (add _start many_m)))
        (set many_m2 (add many_m2 many_m))
      )
    )
    ;;(set start (add _start many_m2))
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

)

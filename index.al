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

  ;; Match - matches a string literal
  (def Match (mac (str) (list _match str 0)))

  ;; matches between high and low ascii character values

  (def Range (mac (lo hi) &{block
    (def c (strings.at input start))
    (if (and (gte c $lo) (lte c $hi)) 1 -1)
  }))

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
            (add and_m1 and_m2) ;; <-- return  value if both match
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

  (def Parser (mac (pattern) (block
      &(fun (input start) {block
        (def _G (def $(quote group) (lists.create 0 0 0 0)))
        (def m $pattern)
        (if (neq -1 m) (lists.get_tail _G) 0)
      })
    )
  ))

  [def Map (mac (rule type value) {block
    (def M &matched)
    &{block
    (def _start start)

    (if (neq -1 (def text_m $rule))
      ;; if the rule matched, copy the text into group list
    (block
      (set start _start)
      (def $(quote matched) text_m) ;;sets the var that the
      (set group
        (lists.set_tail group 1 (lists.create $type $value 0 0)))
    ))
    text_m
  }})]


  (export Match Match)
  (export And And)
  (export Or Or)
  (export Many Many)
  (export More More)
  (export Maybe Maybe)
  (export Group Group)
  (export Text Text)
  (export Parser Parser)
  (export Map Map)
  (export Range Range)
)

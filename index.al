(module
  (def strings (import "acid-strings"))
  (def lists   (import "acid-lists"))


  ;;internals to Match
  (def _Match (mac R (str i) (block
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
  (def Match (mac (str) (list _Match str 0)))

  ;; Range - matches between high and low ascii character values

  (def Range (mac (lo hi) &{block
    (def c (strings.at input start))
    (if (and (gte c $lo) (lte c $hi)) 1 -1)
  }))

  ;; Or - matches a or b (fails if both do not match)

  (def Or (mac (a b)
    &(if (neq -1 (def or_m $a)) or_m (if (neq -1 (def or_m $b)) or_m -1))
  ))

  ;; And - matches a then b (fails if a fails, or a works and b fails)

  (def And [mac (a b)
    &{block
      (def and_start start) ;;_start will be made hygenic
      (if
        (neq -1 (def and_m1 $a))
        [block
          (set start (add and_start and_m1))
          (if (neq -1 (def and_m2 $b)) (add and_m1 and_m2) -1)
        ]
        -1
      )
    }])

  ;; Many - matches 0 or more a. never fails, just matches zero times.

  (def Many [mac (a) &{block
    (def many_m (def many_m2 0))
    (def _start start)
    (loop (neq -1 (def many_m $a))
      (block
        (set start (set _start (add _start many_m)))
        (set many_m2 (add many_m2 many_m))
      )
    )
    many_m2
  }])

  ;; More - matches one or more times. fails if the first match fails.

  (def More [mac (a) &(And $a (Many $a))])

  ;; Maybe - matches zero or one times. never fails.

  (def Maybe [mac (a) &(Or $a 0)])


  ;; Map - transforms a match into a value.
  ;;       takes a rule, a type, and code
  ;;       - type is the sort of list pointer
  ;;         0 - nil, 1 - list, 2 - number, 3 - string
  ;;       - code is is an expression that returns the value.
  ;;         it can see variables input start matched
  ;;         (see Text, below for an example)

  [def Map (mac (rule type code) {block
    (def M &matched)
    &{block
    (def _start start)

    (if (neq -1 (def text_m $rule))
      ;; if the rule matched, copy the text into group list
    (block
      (set start _start)
      (def $(quote matched) text_m) ;;sets the var that the
      (set group
        (lists.set_tail group 1 (lists.create $type $code 0 0)))
    ))
    text_m
  }})]

  ;; Text - captures text around a match.

  ;;        note that this just uses the Map rule, with string.slice

  [def Text (mac (rule)
    &(Map $rule 3 (strings.slice input start (add start matched)))
  )]

  ;; Group - captures a list of items.
  ;;         any captures inside of this rule are added,
  ;;         including other groups

  [def Group (mac (rule) &{block
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

  ;; Parser - takes a rule and returns a parse function, ready for export

  (def Parser (mac (pattern) (block
      &(fun (input start) {block
        ;; note: $(quote group) is a hack so that the "group"
        ;; var isn't changed by hygenic macros...
        (def _G (def $(quote group) (lists.create 0 0 0 0)))
        (def m $pattern)
        (if (neq -1 m) (lists.get_tail _G) 0)
      })
    )
  ))

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

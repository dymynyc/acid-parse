(module
  (def l (import "acid-lists"))

  (export init (fun () (l.create 0 0 0 0)))

  (export append (fun (g t val) (block
    (def _g (l.create t val 0 0))
    (if (eqz (l.get_head g))
      (l.set_tail g 1 (l.set_head g 1 _g))
        ;;remember that evaluation order here is (3 (1 2))
        ;;so (get_tail g) is before (set_tail g _g)
        (l.set_tail (l.get_tail g) 1 (l.set_tail g 1 _g))
    )
  )))

)

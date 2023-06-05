module M = Minisat

let solve_for (n : int) : bool =
  let solver = M.create () in

  (* literal allocator *)
  let mklit =
    let lits = Hashtbl.create 32 in
    let n_ = ref 1 in
    fun ~p ~h : M.Lit.t ->
      try Hashtbl.find lits (p, h)
      with Not_found ->
        let lit = M.Lit.make !n_ in
        incr n_;
        Hashtbl.add lits (p, h) lit;
        lit
  in

  try
    (* each pigeon must be somewhere *)
    for p = 1 to n + 1 do
      let somewhere = Array.init n (fun h -> mklit ~p ~h:(h + 1)) in
      M.add_clause_a solver somewhere
    done;

    (* no collision *)
    for h = 1 to n do
      for p1 = 1 to n + 1 do
        for p2 = 1 to p1 - 1 do
          let c = [ M.Lit.neg (mklit ~p:p1 ~h); M.Lit.neg (mklit ~p:p2 ~h) ] in
          M.add_clause_l solver c
        done
      done
    done;

    M.solve solver;
    true
  with M.Unsat -> false

let () =
  let n = int_of_string Sys.argv.(1) in
  let sat = solve_for n in
  assert (not sat)

#!/usr/bin/env ocaml

print_endline "test1...";;

#directory "_build/src";;
#load "minisat.cma";;

let s = Minisat.create();;
let l1 = Minisat.Lit.make 1;;
let l2 = Minisat.Lit.make 2;;
let l3 = Minisat.Lit.make 3;;
l1;;
Minisat.Lit.neg l1;;
Minisat.Lit.neg l2;;
l1, Minisat.Lit.neg l1, l2, Minisat.Lit.neg l2;;
Minisat.add_clause_l s [l1; Minisat.Lit.neg l2];;
Minisat.add_clause_l s [Minisat.Lit.neg l1; l2];;
Minisat.add_clause_l s [Minisat.Lit.neg l1; Minisat.Lit.neg l3];;
Minisat.add_clause_l s [l1; Minisat.Lit.neg l3];;
Minisat.solve s;;
Minisat.value s l1;;
Minisat.value s l2;;
print_endline "should succeed...";;
Minisat.solve s;; (* should not fail *)
print_endline "ok!";;
print_endline "should fail...";;
try Minisat.solve ~assumptions:[|l3|] s; assert false
with Minisat.Unsat -> print_endline "ok!";; (* should fail *)
print_endline "should succeed...";;
Minisat.solve s;; (* should not fail *)
print_endline "ok!";;

(* This file is free software. See file "license" for more details. *)

type t
type 'a printer = Format.formatter -> 'a -> unit

module Lit = struct
  type t = int

  let[@inline] make n =
    assert (n > 0);
    n + n + 1

  let[@inline] neg n = n lxor 1
  let[@inline] abs n = n land (max_int - 1)
  let equal : t -> t -> bool = ( = )
  let compare : t -> t -> int = compare
  let[@inline] hash (x : t) : int = Hashtbl.hash x

  let[@inline] sign n =
    if n land 1 = 1 then
      true
    else
      false

  let[@inline] to_int n = n lsr 1

  let to_string x =
    (if sign x then
      ""
    else
      "-")
    ^ string_of_int (to_int x)

  let pp out x = Format.pp_print_string out (to_string x)
end

type assumptions = Lit.t array

module Raw = struct
  external create : unit -> t = "caml_minisat_new"
  external delete : t -> unit = "caml_minisat_delete"

  external ensure_var : t -> Lit.t -> unit = "caml_minisat_ensure_var"
    [@@noalloc]

  external add_clause_a : t -> Lit.t array -> bool = "caml_minisat_add_clause_a"
    [@@noalloc]

  external simplify : t -> bool = "caml_minisat_simplify" [@@noalloc]
  external solve : t -> Lit.t array -> bool = "caml_minisat_solve"
  external nvars : t -> int = "caml_minisat_nvars" [@@noalloc]
  external nclauses : t -> int = "caml_minisat_nclauses" [@@noalloc]
  external nconflicts : t -> int = "caml_minisat_nconflicts" [@@noalloc]
  external value : t -> Lit.t -> int = "caml_minisat_value" [@@noalloc]
  external level : t -> Lit.t -> int = "caml_minisat_level" [@@noalloc]
  external set_verbose : t -> int -> unit = "caml_minisat_set_verbose"
  external okay : t -> bool = "caml_minisat_okay" [@@noalloc]
  external core : t -> Lit.t array = "caml_minisat_core"
  external to_dimacs : t -> string -> unit = "caml_minisat_to_dimacs"
  external interrupt : t -> unit = "caml_minisat_interrupt" [@@noalloc]

  external clear_interrupt : t -> unit = "caml_minisat_clear_interrupt"
    [@@noalloc]
end

let create () =
  let s = Raw.create () in
  Gc.finalise Raw.delete s;
  s

exception Unsat

let okay = Raw.okay
let check_ret_ b = if not b then raise Unsat
let ensure_lit_exists s l = Raw.ensure_var s l
let add_clause_a s a = Raw.add_clause_a s a |> check_ret_
let add_clause_l s lits = add_clause_a s (Array.of_list lits)

let pp_clause out l =
  Format.fprintf out "[@[<hv>";
  let first = ref true in
  List.iter
    (fun x ->
      if !first then
        first := false
      else
        Format.fprintf out ",@ ";
      Lit.pp out x)
    l;
  Format.fprintf out "@]]"

let simplify s = Raw.simplify s |> check_ret_
let solve ?(assumptions = [||]) s = Raw.solve s assumptions |> check_ret_
let unsat_core = Raw.core

type value =
  | V_undef
  | V_true
  | V_false

let string_of_value = function
  | V_undef -> "undef"
  | V_true -> "true"
  | V_false -> "false"

let pp_value out x = Format.pp_print_string out (string_of_value x)

let[@inline] value s lit =
  match Raw.value s lit with
  | 1 -> V_true
  | 0 -> V_undef
  | -1 -> V_false
  | _ -> assert false

let level = Raw.level
let set_verbose = Raw.set_verbose
let interrupt = Raw.interrupt
let clear_interrupt = Raw.clear_interrupt
let n_clauses = Raw.nclauses
let n_vars = Raw.nvars
let n_conflicts = Raw.nconflicts

module Debug = struct
  let to_dimacs_file = Raw.to_dimacs
end

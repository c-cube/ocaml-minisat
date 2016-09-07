
(* This file is free software. See file "license" for more details. *)

(** {1 Bindings to Minisat} *)

type t
(** An instance of minisat (stateful) *)

type 'a printer = Format.formatter -> 'a -> unit

module Lit : sig
  type t = private int
  (** Some representation of literals that will be accepted by minisat *)

  val make : int -> t
  val neg : t -> t
  val abs : t -> t
  val sign : t -> bool
  val to_int : t -> int
  val to_string : t -> string
  val pp : t printer
end

type assumptions = Lit.t array

module Raw : sig
  external create : unit -> t = "caml_minisat_new"
  external delete : t -> unit = "caml_minisat_delete"

  (* the [add_clause] functions return [false] if the clause
     immediately makes the problem unsat *)

  external add_clause_a : t -> Lit.t array -> bool = "caml_minisat_add_clause_a"

  external simplify : t -> bool = "caml_minisat_simplify"

  external solve : t -> assumptions -> bool = "caml_minisat_solve"

  external nvars : t -> int = "caml_minisat_nvars"
  external nclauses : t -> int = "caml_minisat_nclauses"
  external nconflicts : t -> int = "caml_minisat_nconflicts"

  external set_nvars : t -> int -> unit = "caml_minisat_set_nvars"

  external value : t -> Lit.t -> int = "caml_minisat_value"

  external set_verbose: t -> int -> unit = "caml_minisat_set_verbose"
end

val create : unit -> t

exception Unsat

val add_clause_l : t -> Lit.t list -> unit
(** @raise Unsat if the problem is unsat *)

val add_clause_a : t -> Lit.t array -> unit
(** @raise Unsat if the problem is unsat *)

val pp_clause : Lit.t list printer

val simplify : t -> unit
(** @raise Unsat if the problem is unsat *)

val solve : ?assumptions:assumptions -> t -> unit
(** @raise Unsat if the problem is unsat *)

type value =
  | V_undef
  | V_true
  | V_false

val value : t -> Lit.t -> value

val set_verbose: t -> int -> unit

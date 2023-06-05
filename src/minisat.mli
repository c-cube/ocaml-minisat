(** Bindings to Minisat. *)

(* This file is free software. See file "license" for more details. *)

type t
(** An instance of minisat (stateful) *)

type 'a printer = Format.formatter -> 'a -> unit

module Lit : sig
  type t = private int
  (** Some representation of literals that will be accepted by minisat.
      {b NOTE} the representation used by minisat is not based on sign
      but parity. Do not try to encode negative literals as negative
      integers. *)

  val make : int -> t
  (** [make n] creates the literal whose index is [n].
      {b NOTE} [n] must be strictly positive. Use {!neg} to obtain
      the negation of a literal. *)

  val neg : t -> t
  (** Negation of a literal.
      Invariant: [neg (neg x) = x] *)

  val abs : t -> t
  (** Absolute value (removes negation if any). *)

  val sign : t -> bool
  (** Sign: [true] if the literal is positive, [false] for a negated literal.
      Invariants:
      [sign (abs x) = true]
      [sign (neg x) = not (sign x)]
  *)

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
    [@@noalloc]

  external simplify : t -> bool = "caml_minisat_simplify" [@@noalloc]
  external solve : t -> assumptions -> bool = "caml_minisat_solve"
  external nvars : t -> int = "caml_minisat_nvars" [@@noalloc]
  external nclauses : t -> int = "caml_minisat_nclauses" [@@noalloc]
  external nconflicts : t -> int = "caml_minisat_nconflicts" [@@noalloc]
  external set_nvars : t -> int -> unit = "caml_minisat_set_nvars" [@@noalloc]
  external value : t -> Lit.t -> int = "caml_minisat_value" [@@noalloc]
  external set_verbose : t -> int -> unit = "caml_minisat_set_verbose"
end

val create : unit -> t
(** Create a fresh solver state. *)

exception Unsat

val add_clause_l : t -> Lit.t list -> unit
(** Add a clause (as a list of literals) to the solver state.

    @raise Unsat if the problem is unsat. *)

val add_clause_a : t -> Lit.t array -> unit
(** Add a clause (as an array of literals) to the solver state.

    @raise Unsat if the problem is unsat. *)

val pp_clause : Lit.t list printer

val simplify : t -> unit
(** Perform simplifications on the solver state. Speeds up later manipulations
    on the solver state, e.g. calls to [solve].

    @raise Unsat if the problem is unsat. *)

val solve : ?assumptions:assumptions -> t -> unit
(** Check whether the current solver state is satisfiable, additionally assuming
    that the literals provided in [assumptions] are assigned to true. After
    [solve] terminates (raising [Unsat] or not), the solver state is unchanged:
    the literals in [assumptions] are only considered to be true for the duration
    of the query.

    @raise Unsat if the problem is unsat. *)

type value =
  | V_undef
  | V_true
  | V_false

val string_of_value : value -> string
(** @since 0.5 *)

val pp_value : value printer
(** @since 0.5 *)

val value : t -> Lit.t -> value
(** Returns the assignation of a literal in the solver state.
    This must only be called after a call to {!solve} that returned successfully
    without raising {!Unsat}. *)

val set_verbose : t -> int -> unit

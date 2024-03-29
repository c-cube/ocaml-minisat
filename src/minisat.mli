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

  val equal : t -> t -> bool
  (** @since 0.6 *)

  val compare : t -> t -> int
  (** @since 0.6 *)

  val hash : t -> int
  (** @since 0.6 *)

  val make : int -> t
  (** [make n] creates the literal whose index is [n].
      {b NOTE} [n] must be strictly positive. Use {!neg} to obtain
      the negation of a literal. *)

  val neg : t -> t
  (** Negation of a literal.
      Invariant: [neg (neg x) = x] *)

  val abs : t -> t
  (** Absolute value (removes negation if any). *)

  val apply_sign : bool -> t -> t
  (** [apply_sign true lit] is [lit]; [apply_sign false lit] is [neg lit] 
      @since 0.6 *)

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

val create : unit -> t
(** Create a fresh solver state. *)

val okay : t -> bool
(** [true] if the solver isn't known to be in an unsat state
    @since 0.6 *)

exception Unsat

val ensure_lit_exists : t -> Lit.t -> unit
(** Make sure the solver decides this literal.
    @since 0.6 *)

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

val value_at_level_0 : t -> Lit.t -> value
(** Returns the assignment level for this literal at level 0, if assigned
    there, or [V_undef].
    If [lit] is not assigned at level 0, this returns [V_undef] even when the
    literal has a value in the current model.
    @since 0.6 *)

val unsat_core : t -> Lit.t array
(** Returns the subset of assumptions of a solver that returned "unsat"
    when called with [solve ~assumptions s].
    @since 0.6
*)

val set_verbose : t -> int -> unit
(** Verbose mode. *)

val interrupt : t -> unit
(** Interrupt the solver, typically from another thread.
    @since 0.6 *)

val clear_interrupt : t -> unit
(** Clear interrupt flag so that we can use the solver again.
    @since 0.6 *)

val n_clauses : t -> int
(** @since 0.6 *)

val n_vars : t -> int
(** @since 0.6 *)

val n_conflicts : t -> int
(** @since 0.6 *)

module Debug : sig
  val to_dimacs_file : t -> string -> unit
  (** [to_dimacs_file solver path] writes the solver's set of clauses into the
    file at [path].
    @since 0.6 *)
end

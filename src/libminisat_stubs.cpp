

#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/threads.h>

#include "assert.h"
#include "core/Solver.h"
#include "core/SolverTypes.h"
#include "mtl/Vec.h"
#include "stdlib.h"
#include "string.h"

using namespace Minisat;

/// Make sure `lit` is valid inside the solver.
void ensureVar(Solver &s, Lit lit) {
  Var v = Minisat::var(lit);
  while (v > s.nVars()) {
    s.newVar(true, true);
  }
}

extern "C" {

CAMLprim value caml_minisat_new(value unit) {
  CAMLparam0();
  CAMLlocal1(block);

  Solver *s = new Solver();

  // allocate a block to store the pointer
  block = caml_alloc_small(sizeof(Solver *), Abstract_tag);
  *((Solver **)(Data_custom_val(block))) = s;

  CAMLreturn(block);
}

// fast access to the solver
static inline Solver *get_solver(value block) {
  Solver *s = *((Solver **)Data_custom_val(block));
  return s;
}

CAMLprim value caml_minisat_delete(value block) {
  CAMLparam1(block);
  Solver *s;

  // already cleaned?
  if (*((Solver **)(Data_custom_val(block))) == 0) {
    goto exit;
  }

  s = get_solver(block);
  delete s;

  // clear block content
  memset(Data_custom_val(block), 0, sizeof(Solver *));

exit:
  CAMLreturn(Val_unit);
}

CAMLprim value caml_minisat_simplify(value block) {
  CAMLparam1(block);

  Solver *s = get_solver(block);
  bool res = s->simplify();

  CAMLreturn(Val_bool(res));
}

// we now directly use the minisat convention!
static inline Lit lit_of_int(int i) { return Minisat::toLit(i); }

CAMLprim value caml_minisat_solve(value block, value v_lits) {
  CAMLparam2(block, v_lits);

  // build an array out of [v_lits]
  size_t lits_size = Wosize_val(v_lits);

  vec<Lit> lits;
  lits.capacity(lits_size);
  Solver *s = get_solver(block);

  for (size_t i = 0; i < lits_size; ++i) {
    Lit lit = lit_of_int(Int_val(Field(v_lits, i)));
    ensureVar(*s, lit);
    lits.push(lit);
  }

  // solve
  caml_release_runtime_system();
  bool res = s->solve(lits);
  caml_acquire_runtime_system();

  CAMLreturn(Val_bool(res));
}

CAMLprim value caml_minisat_add_clause_a(value block, value v_lits) {
  CAMLparam2(block, v_lits);

  // build an array out of [v_lits]
  size_t lits_size = Wosize_val(v_lits);

  Solver *s = get_solver(block);

  vec<Lit> lits;
  lits.capacity(lits_size);
  for (size_t i = 0; i < lits_size; ++i) {
    Lit lit = lit_of_int(Int_val(Field(v_lits, i)));
    ensureVar(*s, lit);
    lits.push(lit);
  }

  bool res = s->addClause(lits);

  CAMLreturn(Val_bool(res));
}

CAMLprim value caml_minisat_value(value block, value v_lit) {
  CAMLparam1(block);

  Solver *s = get_solver(block);

  Lit lit = lit_of_int(Int_val(v_lit));
  int var = Minisat::var(lit);
  lbool cur_val = var > s->nVars() ? l_Undef : s->value(lit);

  /* convert lbool to int */
  int ret;
  if (cur_val == l_Undef)
    ret = 0;
  else if (cur_val == l_True)
    ret = 1;
  else if (cur_val == l_False)
    ret = -1;
  else
    ret = -2;

  CAMLreturn(Val_int(ret));
}

CAMLprim value caml_minisat_core(value block) {
  CAMLparam1(block);
  CAMLlocal1(res);

  Solver *s = get_solver(block);

  vec<Lit> &conflict = s->conflict;
  res = caml_alloc(conflict.size(), 0 /* tag for array */);

  for (int i = 0; i < conflict.size(); ++i) {
    Lit lit = ~conflict[i]; // we want the core, not conflict
    Store_field(res, i, Val_int(Minisat::toInt(lit)));
  }

  CAMLreturn(res);
}

CAMLprim value caml_minisat_set_verbose(value block, value v_lev) {
  CAMLparam1(block);

  int lev = Int_val(v_lev);

  Solver *s = get_solver(block);
  s->verbosity = lev;

  CAMLreturn(Val_unit);
}

CAMLprim value caml_minisat_okay(value block) {
  CAMLparam1(block);

  Solver *s = get_solver(block);
  CAMLreturn(Val_bool(s->okay()));
}

CAMLprim value caml_minisat_to_dimacs(value block, value path) {
  CAMLparam2(block, path);

  Solver *s = get_solver(block);
  char const *file = String_val(path);

  s->toDimacs(file);

  CAMLreturn(Val_unit);
}

CAMLprim value caml_minisat_nvars(value block) {
  CAMLparam1(block);

  Solver *s = get_solver(block);
  CAMLreturn(Val_int(s->nVars()));
}

CAMLprim value caml_minisat_nclauses(value block) {
  CAMLparam1(block);

  Solver *s = get_solver(block);
  CAMLreturn(Val_int(s->nClauses()));
}

CAMLprim value caml_minisat_nconflicts(value block) {
  CAMLparam1(block);

  Solver *s = get_solver(block);
  CAMLreturn(Val_int(s->nLearnts()));
}

CAMLprim value caml_minisat_interrupt(value block) {
  CAMLparam1(block);
  Solver *s = get_solver(block);
  s->interrupt();
  CAMLreturn(Val_unit);
}


CAMLprim value caml_minisat_clear_interrupt(value block) {
  CAMLparam1(block);
  Solver *s = get_solver(block);
  s->clearInterrupt();
  CAMLreturn(Val_unit);
}

} // extern "C"

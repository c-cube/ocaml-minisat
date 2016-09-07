
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>

#include "string.h"
#include "stdlib.h"
#include "assert.h"
#include "solver.h"


CAMLprim value caml_minisat_new(value unit)
{
  CAMLparam0 ();
  CAMLlocal1 (block);

  solver *s = solver_new();

  // allocate a block to store the pointer
  block = caml_alloc_small(sizeof(s), Abstract_tag);
  *((solver**)(Data_custom_val(block))) = s;

  CAMLreturn (block);
}

// fast access to the solver
static inline solver* get_solver(value block)
{
  solver *s = *((solver**)Data_custom_val(block));
  return s;
}

CAMLprim value caml_minisat_delete(value block)
{
  CAMLparam1 (block);

  solver *s = get_solver(block);
  solver_delete(s);

  // clear block content
  memset(((solver**)(Data_custom_val(block))), 0, sizeof(solver*));

  CAMLreturn (Val_unit);
}

CAMLprim value caml_minisat_simplify(value block)
{
  CAMLparam1 (block);

  solver *s = get_solver(block);
  bool res = solver_simplify(s);

  CAMLreturn (Val_bool(res));
}

// we now directly use the minisat convention!
static inline lit lit_of_int(int i) { return i; }

CAMLprim value caml_minisat_solve(value block, value v_lits)
{
  CAMLparam2 (block, v_lits);

  // build an array out of [v_lits]
  size_t lits_size = Wosize_val(v_lits);

  lit* lits = malloc(lits_size * sizeof(lit));
  assert (lits_size == 0 || lits != NULL);

  for (size_t i = 0; i < lits_size; ++i)
  {
    int lit = lit_of_int(Int_val(Field(v_lits, i)));
    lits[i] = lit;
  }

  // solve
  solver *s = get_solver(block);
  bool res = solver_solve(s, lits, lits+lits_size);

  free(lits);

  CAMLreturn (Val_bool(res));
}

CAMLprim value caml_minisat_add_clause_a(value block, value v_lits)
{
  CAMLparam2 (block, v_lits);

  // build an array out of [v_lits]
  size_t lits_size = Wosize_val(v_lits);

  lit* lits = malloc(lits_size * sizeof(lit));
  assert (lits_size == 0 || lits != NULL);

  for (size_t i = 0; i < lits_size; ++i)
  {
    int lit = lit_of_int(Int_val(Field(v_lits, i)));
    lits[i] = lit;
  }

  solver *s = get_solver(block);
  bool res = solver_addclause(s, lits, lits+lits_size);

  free(lits);

  CAMLreturn (Val_bool(res));
}

CAMLprim value caml_minisat_value(value block, value v_lit)
{
  CAMLparam1 (block);

  lit lit = lit_of_int(Int_val(v_lit));

  solver *s = get_solver(block);
  lbool cur_val = s->model.ptr[lit_var(lit)];

  CAMLreturn (Val_int(cur_val));
}


CAMLprim value caml_minisat_set_verbose(value block, value v_lev)
{
  CAMLparam1 (block);

  int lev = Int_val(v_lev);

  solver *s = get_solver(block);
  s->verbosity = lev;

  CAMLreturn (Val_unit);
}

CAMLprim value caml_minisat_nvars(value block)
{
  CAMLparam1 (block);

  solver *s = get_solver(block);
  CAMLreturn (Val_int (solver_nvars(s)));
}

CAMLprim value caml_minisat_nclauses(value block)
{
  CAMLparam1 (block);

  solver *s = get_solver(block);
  CAMLreturn (Val_int (solver_nclauses(s)));
}

CAMLprim value caml_minisat_nconflicts(value block)
{
  CAMLparam1 (block);

  solver *s = get_solver(block);
  CAMLreturn (Val_int (solver_nconflicts(s)));
}

CAMLprim value caml_minisat_set_nvars(value block, value n_var)
{
  CAMLparam2 (block, n_var);

  solver *s = get_solver(block);
  solver_setnvars(s, Int_val(n_var));

  CAMLreturn (Val_unit);
}

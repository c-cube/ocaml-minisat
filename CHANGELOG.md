## 0.6

- migrate from minisat-c 1.14 to minisat 2.2 (in C++); refactor it to build with C++11

- add `Lit.{apply_sign,hash,equal,compare}`
- add `ensure_lit_exists`
- do not call `simplify` implicitly before `solve`
- add `value_at_level_0`
- add `unsat_core`
- add `okay`

## 0.5

- format C and OCaml code
- add `pp_value` and `string_of_value`

## 0.4

- move to github actions for CI
- perf: release runtime lock in `solve`
- perf: fast path for `add_clause`
- perf: annotate some C functions as `noalloc`

## 0.3

- fixes:
  * return code of caml_minisat_value
  * fallthrough comment
  * pointer cast
- update travis file to add 4.09
- only ask for dune 1.0

## 0.2

- migrate to `dune` for build
- upgrades to the CI

## 0.1

- Edits for continous integration:
 * removed symlinks of `src/solver.h`, `src/solver.c`, `src/vec.c`
   and replaced them by the actual files; I did that because
   in cygwin, ocamlc wouldn't find solver.h in `#include "solver.h"`.
   I might be mistaken but it's the only thing I found to avoid the
   problem...
 * modified the uint64 typedef that was causing issues in cygwin+ocamlc.
   In fact, the `#ifdef _WIN32` wasn't proper for cygwin builds;
   plus, the `uint64` isn't standard, changed to `uint64_t`.
   See the SO topic here: http://stackoverflow.com/questions/126279

- initial release

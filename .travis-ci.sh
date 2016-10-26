# Inspired from repo's .travis-ci.sh ocaml/oasis2opam
export OPAMYES=1

if [ -f "$HOME/.opam/config" ]; then
    opam update
    opam upgrade
else
    opam init
fi

if [ -n "${OPAM_SWITCH}" ]; then
    opam switch ${OPAM_SWITCH}
fi
eval `opam config env`

opam install ocamlfind

export OCAMLRUNPARAM=b

ocaml setup.ml -configure --enable-tests
ocaml setup.ml -build
ocaml setup.ml -test

opam pin add minisat .
opam remove minisat
[ -z "`ocamlfind query minisat`" ] || (echo "It uninstalled fine!" && exit 1)
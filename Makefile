
DUNE_OPTS=--profile=release 

build:
	@dune build $(DUNE_OPTS)

clean:
	@dune clean

doc:
	@dune build @doc

test:
	@dune runtest --force --no-buffer

WATCH?="@all"
watch:
	@dune build $(WATCH) $(DUNE_OPTS) -w

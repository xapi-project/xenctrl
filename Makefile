# vim: set noet ts=8:
#
# This Makefile is not called from Opam but only used for
# convenience during development
#

.PHONY: all clean docker

all:
	dune build @install --profile=release

build:
	dune build --profile=dev

install: all
	dune install --profile=release

clean:
	dune clean


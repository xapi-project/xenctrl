
[![Build Status](https://travis-ci.org/lindig/xenctrl.svg?branch=master)](https://travis-ci.org/lindig/xenctrl)

# Mock OCaml Xen Bindings

This is a replacement for _OCaml Xen Low Level Libs_ ([XLLL]): it
provides mock [OCaml] bindings to [Xen] to be used with the
[Citrix Hypervisor] Toolstack for Travis builds. Most of that code is
available from [XS Opam].

The code is taken from [Xen] but mocks some some parts that don't bind
properly to standard [Xen] libraries. As such, this is only useful for
compiling code but not for running it.

## Building

The code assumes that [Xen] is installed such that header files and
libraries are available. This code currently builds on a Debian system
with these packages installed:

* libxen-dev
* libsystemd-dev
* m4
* opam (the OCaml package manager)
* dune (the OCaml build tool - it can be installed from Opam)

To actually build the code, run:

```sh
$ opam install dune
$ make
```

If you are an OCaml developer, you most likely have [Opam] already
installed and configured.

[OCaml]:    https://www.ocam.org/
[Xen]:      http://xenbits.xen.org/
[Citrix Hypervisor]:  https://www.citrix.co.uk/products/citrix-hypervisor/
[dune]:     https://github.com/ocaml/dune
[Opam]:     https://opam.ocaml.org/
[XLLL]:     https://github.com/xapi-project/ocaml-xen-lowlevel-libs

[XS Opam]:  https://github.com/xapi-project/xs-opam
<!-- vim: set et -->

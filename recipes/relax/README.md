Relax (makepad), a live compiler and JIT runtime for Rust, built from upstream for evaluation.

No local patches yet. `relax` must stay in the tree it was built in (it reads its std
from there), so this is a tree recipe and the binary is run from the build tree.

| Patch | Why |
|---|---|
| 0001-promote-drop-free-ctor | `&Variant` of a type with drop glue was a dangling stack temporary (rustc promotes it); build scripts did not get `CARGO_MANIFEST_LINKS` |

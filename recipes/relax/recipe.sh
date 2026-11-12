# Relax, the makepad live compiler and JIT runtime for Rust, built for a trial on our Rust
# crates. Upstream commit as is; the series is empty.
#
# KIND=tree because `relax` reads its own std from the checkout it was built in, so the
# binary must stay inside its build tree. Run it as
#   ~/.cache/build/relax/latest/src/target/release/relax
# or from the installed copy under ~/.local/share/relax/current.
# MODE=patches (no fork): this is an evaluation, nothing is pushed anywhere.

UPSTREAM=https://github.com/makepad/relax.git
MODE=patches
KIND=tree
PIN=5688000b092818257578f4fbb8d8d2acf136315d

lb_install_root() { echo "$HOME/.local/share/relax"; }

lb_build() {
    (cd src && cargo build --release -p relax-runner --bin relax)
    mkdir -p out
    ln -sfn ../src/target/release/relax out/relax
}

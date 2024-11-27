# mtg-solver in Rust

This is the version that I am using to learn Rust and, hopefully,
create a version that is performant enough to run on my S20+.

## Development

* `cargo test` to run unit tests
* `cargo llvm-cov` to establish test coverage
* `cargo run` to run `main.rs`'s code
* `cargo fmt` to reformat the codebase

## Release

* `cargo build --release`

## Maintenance

* Regular `cargo update` to update Cargo.lock

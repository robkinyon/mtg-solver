# mtg-solver in Rust

This is the version that I am using to learn Rust and, hopefully,
create a version that is performant enough to run on my S20+.

The solver models a 60-card goldfish deck with Mountains, Bolts, Mox Ruby,
and Black Lotus. It assumes 20 opposing life, a 7-card opening hand, one
draw each turn, and 3 damage per Bolt. Mox Ruby adds one red mana per turn;
Black Lotus may be sacrificed for three red mana. It optimizes Lotus use
for either the earliest-turn win probability or average kill turn. When
searching unrestricted card counts, Mountains are omitted from the search
because Mox Ruby provides the same mana without using the once-per-turn land
play. Wheel of Fortune is not modeled yet.

## Development

* `cargo test` to run unit tests
* `cargo llvm-cov` to establish test coverage
* `cargo run` to run `main.rs`'s code
* `cargo run --release -- --optimize` to exhaustively search 60-card compositions
* `cargo fmt` to reformat the codebase

## Release

* `cargo build --release`

## Maintenance

* Regular `cargo update` to update Cargo.lock

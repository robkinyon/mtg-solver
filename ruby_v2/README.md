# mtg-solver in Ruby

This is the version that I used to spec out the code and figure out
the work. The solver groups identical cards when it explores draws and
memoizes equivalent game states to avoid visiting redundant probability
paths. It assumes the game algorithm is deterministic and depends only on
the standard `GameState` fields. Set `memoize: false` when using an algorithm
with side effects, external mutable state, or custom state fields.

## Initial Setup

* `sudo apt install ruby bundler`
* `bundle install`

## Development

* `bundle exec rspec` to run the tests
* `bundle exec ./test.rb` to run a thing

The test suite includes 60-card Mountain/Bolt goldfish runs against 20 life.
Those cases check the complete ordered-permutation totals and the number of
deals that win on the earliest turn. They provide a baseline for comparing
deck compositions; they do not yet search for an optimal composition.

## Release

* No release process (yet)

## Maintenance

* No maintenance process (yet)

require 'mtg/solver/version'

Gem::Specification.new do |s|
  s.name    = 'mtg-solver'
  s.version = MTG::Solver::VERSION
  s.author  = 'Rob Kinyon'
  s.email   = 'rob.kinyon@gmail.com'
  s.summary = 'Magic: the Gathering solver'
  s.description = 'A solver for Magic: the Gathering decks in goldfish mode'
  s.license = 'MIT'
  s.homepage = 'https://github.com/robkinyon/mtg-solver'

  # Don't tramp along our dot-files, except for .rspec
  s.files         = `git ls-files`.split("\n").select { |filename|
    !filename.match(/^\./) || filename == '.rspec'
  }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- {bin}/*`.split("\n")
  s.require_paths = %w(lib)

  s.required_ruby_version = '>= 3'

  s.add_dependency 'unique_permutation'

  s.add_development_dependency 'rake', '~> 10'
  s.add_development_dependency 'rspec', '~> 3.0.0', '>= 3.0.0'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'rubygems-tasks', '~> 0'
  s.add_development_dependency 'json', '~> 1', '>=1.7.7'
end

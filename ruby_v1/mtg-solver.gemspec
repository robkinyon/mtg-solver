#require 'mtg/solver/version'

Gem::Specification.new do |s|
  s.name    = 'mtg-solver'
  s.version = '0.0.1' #MTG::Solver::VERSION
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
  #s.add_dependency 'erb', '<6'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'json'
end

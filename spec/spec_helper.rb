RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'mtg/solver'

def run_test(deck:, conditions:, expected:)
  solver = MTG::Solver.new(
    deck: deck,
    **conditions,
  )
  solver.solve
  expect(solver.wins).to eq(expected)
end

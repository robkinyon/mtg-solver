RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'mtg/solver'

def run_test(deck:, conditions:, expected:, calls:)
  algo = Proc.new do |g|
    g.play(card: MTG::Solver::Card.land, destination: g.in_play)
    mana = g.in_play.length
    while mana > 0
      if g.play(card: MTG::Solver::Card.bolt, destination: g.graveyard)
        mana -= g.mana_per_bolt
        g.opponent_life -= g.dmg_per_bolt
      else
        break
      end
    end
  end
  solver = MTG::Solver.new(
    deck: deck,
    algo: algo,
    **conditions,
  )
  solver.solve
  expect(solver.wins).to eq(expected)
  expect(solver.calls).to eq(calls)
end

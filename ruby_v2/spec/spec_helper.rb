RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'mtg/solver'

def starting_hand_test(decklist:, initial_draw:, expected:)
  solver = MTG::Solver.new(
    decklist: decklist,
    algo: "fake",
    initial_draw: initial_draw,
  )
  expect(solver.starting_hand).to match_array(expected)
end

def run_test(deck:, conditions:, expected:)
  algo = Proc.new do |g|
    g.play(card: MTG::Solver::Card.land, destination: "in_play")
    mana = g.in_play[MTG::Solver::Card.land]
    while mana >= g.mana_per_bolt
      if g.play(card: MTG::Solver::Card.bolt, destination: "graveyard")
        mana -= g.mana_per_bolt
        g.opponent_life -= g.dmg_per_bolt
      else
        break
      end
    end
  end

  solver = MTG::Solver.new(
    decklist: deck,
    algo: algo,
    **conditions,
  )
  solver.solve

  expect(solver.wins).to eq(expected)
  # expect(solver.calls).to eq(calls)
  # expect(solver.total).to eq(total)
  # expect(solver.permutations).to eq(permutations)
end

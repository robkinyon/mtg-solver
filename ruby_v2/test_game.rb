#!/usr/bin/env ruby

puts "Hello"

$:.unshift "lib"
require "mtg/solver"

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

decklist = {
  MTG::Solver::Card.land => 1,
  MTG::Solver::Card.bolt => 2,
}

solver = MTG::Solver.new(
  decklist: decklist,
  algo: algo,
  opponent_life: 1,
  initial_draw: 1,
  lands_per_turn: 1,
  mana_per_bolt: 1,
  dmg_per_bolt: 1,
)
solver.solve
puts "Result: #{solver.wins}"

puts "Ok"

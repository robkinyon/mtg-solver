#!/usr/bin/env ruby

puts "Hello"

$:.unshift "lib"
require "mtg/solver"

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

deck = [
  MTG::Solver::Card.land,
  MTG::Solver::Card.land,
  MTG::Solver::Card.land,
  MTG::Solver::Card.land,
  MTG::Solver::Card.land,
  MTG::Solver::Card.land,
  MTG::Solver::Card.land,
  MTG::Solver::Card.bolt,
  MTG::Solver::Card.bolt,
  MTG::Solver::Card.bolt,
  MTG::Solver::Card.bolt,
  MTG::Solver::Card.bolt,
  MTG::Solver::Card.bolt,
  MTG::Solver::Card.bolt,
  MTG::Solver::Card.land,
]

turn = MTG::Solver::Game.new(
  deck: deck,
  algo: algo,
  initial_life: 20,
  initial_draw: 7,
  lands_per_turn: 1,
  mana_per_bolt: 1,
  dmg_per_bolt: 3,
).run

puts turn

puts "Ok"

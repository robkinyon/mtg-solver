#!/usr/bin/env ruby

require 'unique_permutation'

puts "Hello"

$:.unshift "./lib"
require "mtg/solver"

deck = [
    MTG::Solver.land(),
    MTG::Solver.land(),
    MTG::Solver.land(),
    MTG::Solver.land(),
    MTG::Solver.land(),
    MTG::Solver.land(),
    MTG::Solver.land(),
    MTG::Solver.bolt(),
    MTG::Solver.bolt(),
    MTG::Solver.bolt(),
    MTG::Solver.bolt(),
    MTG::Solver.bolt(),
    MTG::Solver.bolt(),
    MTG::Solver.bolt(),
]

solver = MTG::Solver.new(deck)
wins = {}
solver.deck.unique_permutation do |combo|
    turn = solver.find_winning_turn(combo)
    if ! wins.include? turn
        wins[turn] = 0
    end
    wins[turn] += 1
end

puts wins
puts wins.values.sum

puts "Ok"

#!/usr/bin/env ruby

require 'unique_permutation'

puts "Hello"

$:.unshift "./lib"
require "mtg/solver"

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
]

solver = MTG::Solver.new(deck: deck)
solver.solve

puts solver.wins
puts solver.wins.values.sum

puts "Ok"

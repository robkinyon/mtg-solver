#!/usr/bin/env ruby

puts "Hello"

$:.unshift "./lib"
require "mtg/solver"

deck = {
  MTG::Solver::Card.land => 7,
  MTG::Solver::Card.bolt => 7,
}

solver = MTG::Solver.new(deck: deck)
solver.solve

puts solver.wins
puts solver.wins.values.sum

puts "Ok"

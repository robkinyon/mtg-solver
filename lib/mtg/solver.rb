require 'unique_permutation'

require "mtg/solver/version"
require "mtg/solver/cards"
require "mtg/solver/game"

class MTG::Solver
  attr_accessor :deck, :wins

  attr_accessor :initial_life
  attr_accessor :initial_draw, :lands_per_turn, :mana_per_bolt

  def initialize(
    deck:,
    initial_draw: 7,
    lands_per_turn: 1,
    mana_per_bolt: 1,
    initial_life: 7
  )
    @initial_draw = initial_draw
    @lands_per_turn = lands_per_turn
    @mana_per_bolt = mana_per_bolt
    @initial_life = initial_life

    @deck = []
    deck.each do |card, num|
      (1..num).each {@deck.concat([card])}
    end
    @wins = {}
  end

  def solve
    self.deck.unique_permutation do |combo|
      turn = find_winning_turn(deck: combo)
      if ! self.wins.include? turn
        self.wins[turn] = 0
      end
      self.wins[turn] += 1
    end
  end

  def find_winning_turn(deck:)
    MTG::Solver::Game.new(
      deck: deck,
      initial_draw: self.initial_draw,
      lands_per_turn: self.lands_per_turn,
      mana_per_bolt: self.mana_per_bolt,
      initial_life: self.initial_life,
    ).run
  end
end

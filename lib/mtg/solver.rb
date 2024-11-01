require "mtg/solver/version"
require "mtg/solver/cards"
require "mtg/solver/game"

class MTG::Solver
  attr_accessor :deck, :wins

  def initialize(deck:)
    @deck = deck
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
    MTG::Solver::Game.new(deck: deck).play
  end
end

require 'unique_permutationx'

require "mtg/solver/version"
require "mtg/solver/cards"
require "mtg/solver/game"

class MTG::Solver
  attr_accessor :deck, :wins, :algo, :calls, :total, :permutations

  attr_accessor :initial_life
  attr_accessor :initial_draw, :lands_per_turn
  attr_accessor :mana_per_bolt, :dmg_per_bolt

  def initialize(
    deck:,
    algo:,
    initial_life: 7,
    initial_draw: 7,
    lands_per_turn: 1,
    mana_per_bolt: 1,
    dmg_per_bolt: 1
  )
    @initial_life = initial_life
    @initial_draw = initial_draw
    @lands_per_turn = lands_per_turn
    @mana_per_bolt = mana_per_bolt
    @dmg_per_bolt = dmg_per_bolt

    @algo = algo
    @deck = []
    deck.each do |card, num|
      (1..num).each {@deck.concat([card])}
    end
    @wins = {}
    @calls = false
    @total = false
    @permutations = 1
    1.upto(@deck.length) {|x| @permutations *= x}
  end

  def solve
    rv, calls, total = self.deck.unique_permutation do |combo|
      turn = find_winning_turn(deck: combo)
      if turn == "E"
        next 0
      end
      next turn + self.initial_draw
    end
    self.calls = calls
    self.total = total
    rv.each_key do |k|
      if k == 0
        turn = "E"
      else
        turn = k - self.initial_draw
      end
      if ! self.wins.include? turn
        self.wins[turn] = 0
      end
      self.wins[turn] += rv[k]
    end
  end

  def find_winning_turn(deck:)
    MTG::Solver::Game.new(
      deck: deck,
      algo: @algo,
      initial_life: self.initial_life,
      initial_draw: self.initial_draw,
      lands_per_turn: self.lands_per_turn,
      mana_per_bolt: self.mana_per_bolt,
      dmg_per_bolt: self.dmg_per_bolt,
    ).run
  end
end

require 'mtg/solver/version'
require 'mtg/solver/cards'

# TODO:
# * Handle deck exhaustion later
# * Represent tapping land

class MTG::Solver::Game
  attr_accessor :deck, :hand, :in_play, :graveyard, :out_of_play
  attr_accessor :opponent_life
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

    @opponent_life = initial_life
    @deck = deck
    @hand = []
    @in_play = []
    @graveyard = []
    @out_of_play = []
  end

  def play
    turn = 0
    draw(num: self.initial_draw)
    while self.opponent_life > 0
      turn += 1
      draw
      if hand.include?(MTG::Solver::Card::land)
        play_land
      end
      mana = self.in_play.length
      while mana > 0 && hand.include?(MTG::Solver::Card::bolt)
        play_bolt
        mana -= self.mana_per_bolt
      end
    end
    return turn
  end

  def draw(num: 1)
    self.hand.concat self.deck.slice!(0, num)
  end

  def play_bolt
    self.graveyard.concat self.hand.slice!(self.hand.index(MTG::Solver::Card::bolt), 1)
    self.opponent_life -= 1
  end

  def play_land
    self.in_play.concat self.hand.slice!(self.hand.index(MTG::Solver::Card::land), 1)
  end
end

require 'mtg/solver/version'
require 'mtg/solver/cards'

# TODO:
# * Represent tapping land
# * Add hand limits

class MTG::Solver::Game
  class DeckExhaustedError < StandardError
  end

  # These are the in-game elements
  attr_accessor :deck, :hand, :in_play, :graveyard, :out_of_play

  # These are the game rule options
  attr_accessor :opponent_life
  attr_accessor :initial_draw, :lands_per_turn

  # This needs to be shoved into the card
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
    @initial_draw = initial_draw
    @opponent_life = initial_life
    @lands_per_turn = lands_per_turn
    @mana_per_bolt = mana_per_bolt
    @dmg_per_bolt = dmg_per_bolt

    @algo = algo
    @deck = deck
    @hand = []
    @in_play = []
    @graveyard = []
    @out_of_play = []
  end

  def run
    turn = 0
    draw(num: self.initial_draw)
    while self.opponent_life > 0
      turn += 1
      draw
      @algo.call self
      # play(card: MTG::Solver::Card.land, destination: self.in_play)
      # mana = self.in_play.length
      # while mana > 0
      #   if play(card: MTG::Solver::Card.bolt, destination: self.graveyard)
      #     mana -= self.mana_per_bolt
      #     self.opponent_life -= self.dmg_per_bolt
      #   else
      #     break
      #   end
      # end
    end
    return turn
  rescue DeckExhaustedError
    return "E"
  end

  def draw(num: 1)
    if self.deck.length < num
      raise DeckExhaustedError
    end
    self.hand.concat self.deck.slice!(0, num)
  end

  def play(card:, destination:)
    if hand.include?(card)
      destination.concat self.hand.slice!(self.hand.index(card), 1)
      return true
    end
    return false
  end
end

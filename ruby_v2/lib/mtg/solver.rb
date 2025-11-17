require "mtg/solver/version"
require "mtg/solver/cards"
require "mtg/solver/game"

class MTG::Solver
  attr_accessor :initial_life
  attr_accessor :initial_draw, :lands_per_turn
  attr_accessor :mana_per_bolt, :dmg_per_bolt

  attr_reader :algo, :decklist, :wins

  def initialize(
    decklist:,
    algo:,
    opponent_life: 7,
    initial_draw: 7,
    lands_per_turn: 1,
    mana_per_bolt: 1,
    dmg_per_bolt: 1
  )
    @opponent_life = opponent_life
    @initial_draw = initial_draw
    @lands_per_turn = lands_per_turn
    @mana_per_bolt = mana_per_bolt
    @dmg_per_bolt = dmg_per_bolt

    @algo = algo
    @decklist = decklist

    @decksize = 0
    @decklist.each_value {|count| @decksize += count}
    @wins = Hash.new(0)
  end

  def list_to_hash(input)
    rv = Hash.new(0)
    input.each do |item|
      rv[item] += 1
    end
    return rv
  end

  def hash_to_list(input)
    rv = []
    input.each do |item, count|
      rv << [item] * count
    end
    return rv.flatten
  end

  def starting_hand(&block)
    return enum_for(:starting_hand) unless block_given?

    # This is a sorted version of the main odometer algorithm.
    # decklist = @decklist.clone
    # hand = {}
    # while True do
    #   -> Add this slot's odometer by populating it with the available cards
    #   -> at this point.
    #   odoms.push([e for e in deck.keys() if deck[e] > 0].sort)
    #
    #   card = odoms[-1].shift
    #   decklist[card] -= 1
    #   hand[card] += 1
    #
    #   if hand.len < @initial_draw
    #     continue
    #   end
    #
    #   yield hand
    #
    #   hand[card] -= 1
    #   decklist[card] += 1
    #
    # end

    hash_to_list(@decklist).combination(@initial_draw).to_a.uniq.each do |hand|
      yield list_to_hash(hand)
    end
  end

  def solve
    starting_hand.each do |hand|
      # clone the decklist and decrement it for the starting hand
      this_decklist = @decklist.clone
      hand.each {|card, count| this_decklist[card] -= count}

      # create the Game object
      #  --> Stack of game states
      #  --> Game state contains permanents, graveyard, hand, life remaining
      #    --> State is end of turn, after algo has run
      game = MTG::Solver::Game.new(
        algo: @algo,
        initial_hand: hand,
        opponent_life: @opponent_life,
        lands_per_turn: @lands_per_turn,
        mana_per_bolt: @mana_per_bolt,
        dmg_per_bolt: @dmg_per_bolt,
      )
      odoms = []

      odoms.push(this_decklist.keys.filter{|e| e if this_decklist[e] > 0})
      card = odoms[-1].pop()
      game.run(card: card)
      if game.finished?
        @wins[game.turn] += 1
      end

      #  while True:
      #      -> Add this slot's odometer by populating it with the available cards
      #      -> at this point.
      #      odoms.push([e for e in deck.keys() if deck[e] > 0])
      #
      #      -> It doesn't matter which card is grabbed at any given moment.
      #      card = odoms[-1].pop()
      #
      #      decklist[card] -= 1
      #      game_finished = algo(game, card)
      #      if not game_finished:
      #          continue
      #
      #      -> Capture probability of this sequence leading the deck by calculating
      #      -> the combination of cards remaining
      #      wins[game.turn()] += remaining_probabilities(decklist)
      #
      #      last_game_state = game.pop_last_gamestate()
      #      decklist[last_game_state.card()] += 1
      #
      #      while !odoms.empty? 0 && odoms[-1].empty?
      #          odoms.pop(-1)
      #          last_game_state = game.pop_last_gamestate()
      #          decklist[last_game_state.card()] += 1
      #
      #      if odoms.empty?
      #          break
    end
  end
end

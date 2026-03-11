require 'logger'
require "pp"

$logger = Logger.new(STDOUT)
$logger.level = ENV["DEBUG"] ? Logger::DEBUG : Logger::INFO
$logger.formatter = proc do |severity, datetime, progname, msg|
  "#{msg}\n"
end

require "mtg/solver/version"
require "mtg/solver/cards"
require "mtg/solver/game"

class MTG::Solver
  attr_accessor :initial_life
  attr_accessor :initial_draw, :lands_per_turn
  attr_accessor :mana_per_bolt, :dmg_per_bolt

  attr_reader :algo, :decklist, :wins, :decksize

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

    @decksize = @decklist.each_value.sum
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

  def factorial(n)
    (1..n).inject(:*) || 1
  end

  def binomial_coefficient(n,k)
    factorial(n)/(factorial(k)*factorial(n-k))
    # Also, permutation(n,k) / factorial(k)
  end

  def permutation(n,k)
    factorial(n)/factorial(n-k)
  end

  # Multivariate Hypergeometric Distribution
  # https://en.wikipedia.org/wiki/Hypergeometric_distribution#Multivariate_hypergeometric_distribution
  def mvhd(decklist, hand)
    hand.keys.reduce(1) {|m,card|
      m * binomial_coefficient(decklist[card], hand[card])
    }.to_f / binomial_coefficient(decklist.values.sum, hand.values.sum)
  end

  def hand_probability(hand)
    # Calculates ordered permutations for drawing this hand from the deck
    # Product of P(n_i, k_i) for each card type × multinomial coefficient
    hand.keys.reduce(1) {|m,card|
      m * permutation(@decklist[card], hand[card])
    } * (
      factorial(hand.values.sum) /
      hand.values.reduce(1){|m,value|
        m * factorial(value)
      }
    )
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

    hash_to_list(@decklist).combination(@initial_draw).to_a.uniq.each do |hand_list|
      hand = list_to_hash(hand_list)
      p = hand_probability(hand)
      yield hand, p
    end
  end

  def unique_cards(cardlist)
    cardlist.keys.filter{|e| e if cardlist[e] > 0}
  end

  def all_cards(cardlist)
    cards = []
    cardlist.each do |card, count|
      count.times { cards << card }
    end
    cards
  end

  def solve
    starting_hand.each do |hand, hand_probability|
      # clone the decklist and decrement it for the starting hand
      this_decklist = @decklist.clone
      hand.each {|card, count| this_decklist[card] -= count}
      $logger.debug "****\nH: #{hand} / P: #{hand_probability} / W: #{@wins}"

      # Iterate through all possible remaining card position permutations
      remaining_cards = hash_to_list(this_decklist)
      explore_permutations(
        remaining_cards: remaining_cards,
        game: MTG::Solver::Game.new(
          algo: @algo,
          initial_hand: hand,
          opponent_life: @opponent_life,
          lands_per_turn: @lands_per_turn,
          mana_per_bolt: @mana_per_bolt,
          dmg_per_bolt: @dmg_per_bolt,
        ),
        hand_probability: hand_probability,
        index: 0
      )
    end
  end

  def explore_permutations(remaining_cards:, game:, hand_probability:, index:)
    # If all cards drawn or deck exhausted
    if index >= remaining_cards.length
      # Record outcome
      outcome = game.finished? ? game.turn : "E"
      @wins[outcome] += hand_probability
      return
    end

    # Try each remaining card at this position
    (index...remaining_cards.length).each do |next_index|
      # Swap cards
      remaining_cards[index], remaining_cards[next_index] = remaining_cards[next_index], remaining_cards[index]
      
      # Draw this card and run game only if not finished
      card = remaining_cards[index]
      initial_game_states_length = game.game_states.length
      if !game.finished?
        game.run(card: card)
      end
      
      # Recurse to next position
      explore_permutations(
        remaining_cards: remaining_cards,
        game: game,
        hand_probability: hand_probability,
        index: index + 1
      )
      
      # Backtrack - only pop if we actually added a game state
      if game.game_states.length > initial_game_states_length
        game.pop_last_gamestate
      end
      
      # Swap back
      remaining_cards[index], remaining_cards[next_index] = remaining_cards[next_index], remaining_cards[index]
    end
  end
end

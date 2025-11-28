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

  def binomial_coefficient(d,h)
    factorial(d)/(factorial(h)*factorial(d-h))
  end

  def permutation(d,h)
    factorial(d)/(factorial(d-h))
  end

  def hand_probability(hand)
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

  def solve
    starting_hand.each do |hand, hand_probability|
      # clone the decklist and decrement it for the starting hand
      this_decklist = @decklist.clone
      hand.each {|card, count| this_decklist[card] -= count}
      $logger.debug "****\nH: #{hand} / P: #{hand_probability} / W: #{@wins}"

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
      remaining_probabilities = []
      deck_exhausted = false
      while true
        $logger.debug "O1: #{odoms} / T: #{game.turn}"
        if odoms.empty? || odoms.length <= game.turn
          # If we don't have any cards more to draw, then we have hit deck exhaustion.
          if this_decklist.values.sum == 0
            $logger.debug "EX: #{hand_probability}"
            deck_exhausted = true
          else
            odoms.push(this_decklist.keys.filter{|e| e if this_decklist[e] > 0})
          end
        end
        $logger.debug "O2: #{odoms}"

        remaining_probabilities[game.turn] = this_decklist.values.reduce(1) {|m,n|
          m*factorial(n)
        }
        #remaining_probabilities[game.turn] = factorial(this_decklist.values.sum)

        if !deck_exhausted
          card = odoms[-1].shift
          this_decklist[card] -= 1
          $logger.debug "RP: #{remaining_probabilities}"

          game.run(card: card)
          $logger.debug "O3: #{odoms}"
          next if !game.finished?

          # Capture probability of this sequence leading the deck by calculating
          # the combination of cards remaining
          $logger.debug "W: #{@wins} / #{game.turn} / #{remaining_probabilities}"
          $logger.debug "DL2: #{this_decklist}"

          winning_turn = game.turn
        else
          $logger.debug "HP: #{hand_probability} / RP: #{remaining_probabilities}"
          winning_turn = "E"
          deck_exhausted = false
        end

        # First, pop the last turn played.
        last_game_state = game.pop_last_gamestate
        this_decklist[last_game_state.card] += 1
        $logger.debug "DL3: #{this_decklist}"

        # Then, while the last odometer is empty, pop it and the last turn played.
        while !odoms.empty? && odoms[-1].empty?
          odoms.pop
          # I don't know why this works (yet)
          remaining_probabilities.pop if remaining_probabilities.length > 1
          last_game_state = game.pop_last_gamestate
          this_decklist[last_game_state.card] += 1 if last_game_state.card
          $logger.debug "DL4: #{this_decklist}"
        end

        @wins[winning_turn] += remaining_probabilities[-1] * hand_probability

        $logger.debug "DL5: #{this_decklist}"

        break if odoms.empty?
      end
    end
  end
end

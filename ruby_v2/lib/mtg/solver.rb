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
    dmg_per_bolt: 1,
    memoize: true
  )
    @opponent_life = opponent_life
    @initial_draw = initial_draw
    @lands_per_turn = lands_per_turn
    @mana_per_bolt = mana_per_bolt
    @dmg_per_bolt = dmg_per_bolt
    @memoize = memoize

    @algo = algo
    @decklist = decklist
    @card_types = @decklist.keys

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

    enumerate_starting_hands(
      card_types: @card_types,
      index: 0,
      cards_to_draw: @initial_draw,
      hand: Hash.new(0),
      &block
    )
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
    @memo = {} if @memoize

    starting_hand.each do |hand, hand_probability|
      this_decklist = @decklist.clone
      hand.each {|card, count| this_decklist[card] -= count}
      $logger.debug "****\nH: #{hand} / P: #{hand_probability} / W: #{@wins}"

      outcomes = explore_permutations(
        remaining_cards: this_decklist,
        game: MTG::Solver::Game.new(
          algo: @algo,
          initial_hand: hand,
          opponent_life: @opponent_life,
          lands_per_turn: @lands_per_turn,
          mana_per_bolt: @mana_per_bolt,
          dmg_per_bolt: @dmg_per_bolt,
        )
      )
      outcomes.each do |outcome, count|
        @wins[outcome] += hand_probability * count
      end
    end
  end

  def explore_permutations(remaining_cards:, game:)
    remaining_count = remaining_cards.values.sum

    if game.finished? || remaining_count.zero?
      outcome = game.finished? ? game.turn : "E"
      return { outcome => factorial(remaining_count) }
    end

    key = game_state_key(remaining_cards, game) if @memoize
    return @memo[key] if @memoize && @memo.key?(key)

    outcomes = Hash.new(0)
    remaining_cards.each do |card, count|
      next if count.zero?

      remaining_cards[card] -= 1
      game.run(card: card)
      branch_outcomes = explore_permutations(
        remaining_cards: remaining_cards,
        game: game
      )
      branch_outcomes.each do |outcome, branch_count|
        outcomes[outcome] += count * branch_count
      end
      game.pop_last_gamestate
      remaining_cards[card] += 1
    end

    @memo[key] = outcomes.freeze if @memoize
    outcomes
  end

  private

  def enumerate_starting_hands(card_types:, index:, cards_to_draw:, hand:, &block)
    if index == card_types.length
      yield hand.dup, hand_probability(hand) if cards_to_draw.zero?
      return
    end

    card = card_types[index]
    cards_after = card_types[(index + 1)..].sum { |type| @decklist[type] }
    min_count = [0, cards_to_draw - cards_after].max
    max_count = [@decklist[card], cards_to_draw].min

    (min_count..max_count).each do |count|
      hand[card] = count if count.positive?
      enumerate_starting_hands(
        card_types: card_types,
        index: index + 1,
        cards_to_draw: cards_to_draw - count,
        hand: hand,
        &block
      )
      hand.delete(card) if count.positive?
    end
  end

  def game_state_key(remaining_cards, game)
    state = game.game_states[-1]
    [
      @card_types.map { |card| remaining_cards[card] },
      state.algo.object_id,
      state.turn,
      state.opponent_life,
      @card_types.map { |card| state.hand[card] },
      @card_types.map { |card| state.in_play[card] },
      state.graveyard.dup,
      @card_types.map { |card| state.out_of_play[card] },
      state.card,
      state.lands_per_turn,
      state.mana_per_bolt,
      state.dmg_per_bolt,
    ]
  end
end

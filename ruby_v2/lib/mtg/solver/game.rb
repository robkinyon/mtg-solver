class MTG::Solver::GameState
  attr_accessor :opponent_life
  attr_accessor :hand, :in_play, :graveyard, :out_of_play, :card
  attr_accessor :lands_per_turn, :mana_per_bolt, :dmg_per_bolt
  attr_accessor :algo

  # Create a clone() method to handle the prev_state path
  def initialize(
    algo: nil,
    prev_state: nil,
    card: nil,
    hand: nil,
    opponent_life: nil,
    lands_per_turn: nil,
    mana_per_bolt: nil,
    dmg_per_bolt: nil
  )
    if prev_state
      @algo           = prev_state.algo
      @opponent_life  = prev_state.opponent_life
      @lands_per_turn = prev_state.lands_per_turn.clone
      @mana_per_bolt  = prev_state.mana_per_bolt.clone
      @dmg_per_bolt   = prev_state.dmg_per_bolt.clone
      @hand           = prev_state.hand.clone
      @in_play        = prev_state.in_play.clone
      @graveyard      = prev_state.graveyard.clone
      @out_of_play    = prev_state.out_of_play.clone
      @card           = card
    else
      @algo           = algo
      @opponent_life  = opponent_life
      @lands_per_turn = lands_per_turn
      @mana_per_bolt  = mana_per_bolt
      @dmg_per_bolt   = dmg_per_bolt
      @hand           = hand
      @in_play        = Hash.new(0)
      @graveyard      = Array.new()
      @out_of_play    = Hash.new(0)
      @card           = card
    end
  end

  def run
    @hand[@card] += 1
    @algo.call self
  end

  def play(card:, destination:)
    return false if @hand[card] == 0

    @hand[card] -= 1

    # The graveyard is a list because it's ordered. The other destinations
    # are unordered, so they are hashes.
    case destination
    when "graveyard"
      @graveyard << card
    when "in_play"
      @in_play[card] += 1
    when "out_of_play"
      @out_of_play[card] += 1
    else
      puts "Received '#{destination}' which wasn't understood"
      return false
    end
    return true
  end

  def finished?
    return @opponent_life <= 0
  end
end

class MTG::Solver::Game
  class DeckExhaustedError < StandardError
  end

  attr_accessor :algo, :game_states

  # These are the game rule options
  # attr_accessor :opponent_life, :lands_per_turn

  # This needs to be shoved into the card
  # attr_accessor :mana_per_bolt, :dmg_per_bolt

  def initialize(
    algo:,
    initial_hand:,
    opponent_life: 7,
    lands_per_turn: 1,
    mana_per_bolt: 1,
    dmg_per_bolt: 1
  )
    @game_states = [
      # This is the game state after the initial draw, before the first turn.
      MTG::Solver::GameState.new(
        algo: algo,
        prev_state: nil,
        opponent_life: opponent_life,
        lands_per_turn: lands_per_turn,
        mana_per_bolt: mana_per_bolt,
        dmg_per_bolt: dmg_per_bolt,
        hand: initial_hand,
      )
    ]
  end

  def turn
    return @game_states.length - 1
  end

  def run(card:)
    new_game_state = MTG::Solver::GameState.new(
      prev_state: @game_states[-1],
      card: card,
    )
    @game_states << new_game_state
    new_game_state.run
  end

  def finished?
    return game_states[-1].finished?
  end

  def pop_last_gamestate
    return game_states.pop
  end
end

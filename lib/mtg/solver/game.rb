require 'mtg/solver/version'

# TODO:
# * Handle deck exhaustion later
# * Represent tapping land

class MTG::Solver::Game
    attr :deck, :hand, :play, :graveyard, :out_of_play
    attr :life
    def initialize(deck)
        @deck = deck
        @hand = []
        @play = []
        @graveyard = []
        @out_of_play = []
        @life = 7
    end

    def play
        initial_draw(7)
        turn = 0
        while life > 0
            turn += 1
            draw
            if hand.include? "L"
                play_land
            end
            mana = @play.length
            while mana > 0 && hand.include?("B")
                play_bolt
                mana -= 1
            end
        end
        return turn
    end

    def draw
        @hand.concat @deck.slice!(0, 1)
    end

    def play_bolt
        @graveyard.push @hand.slice!(@hand.index("B"))
        @life -= 1
    end

    def play_land
        @play.push @hand.slice!(@hand.index("L"))
    end

    def initial_draw(num)
        @hand.concat @deck.slice!(0, num)
    end
end
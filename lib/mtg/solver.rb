require "mtg/solver/version"
require "mtg/solver/game"
class MTG::Solver
    attr :deck
    def initialize(deck)
        @deck = deck
    end

    def self.land
        return "L"
    end
    def self.bolt
        return "B"
    end

    def find_winning_turn(bcd)
        game = MTG::Solver::Game.new(bcd)
        return game.play
    end
end
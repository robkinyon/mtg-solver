describe MTG::Solver::GameState do
  describe "#play" do
    it "keeps the card in hand when the destination is invalid" do
      card = MTG::Solver::Card.bolt
      hand = Hash.new(0)
      hand[card] = 1
      game_state = described_class.new(hand: hand)

      expect(game_state.play(card: card, destination: "invalid")).to be(false)
      expect(game_state.hand[card]).to eq(1)
    end
  end
end

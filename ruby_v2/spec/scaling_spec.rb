describe "60-card goldfish decks" do
  {
    "20 Mountains / 40 Bolts" => {
      lands: 20,
      bolts: 40,
      earliest_turn_count: 8531678614256980955288135520797900254987279872580519641058010726400000000000000,
    },
    "30 Mountains / 30 Bolts" => {
      lands: 30,
      bolts: 30,
      earliest_turn_count: 4257422334237813421225094011319100870600039857491540912059187200000000000000,
    },
    "40 Mountains / 20 Bolts" => {
      lands: 40,
      bolts: 20,
      earliest_turn_count: 254085367182825271718527600586576445803074868446746378240000000000000,
    },
  }.each do |description, deck|
    it "counts all permutations for #{description} against 20 life" do
      solver = MTG::Solver.new(
        decklist: {
          MTG::Solver::Card.land => deck[:lands],
          MTG::Solver::Card.bolt => deck[:bolts],
        },
        algo: goldfish_algo,
        opponent_life: 20,
        initial_draw: 7,
      )

      solver.solve

      expect(solver.wins.values.sum).to eq(solver.factorial(60))
      expect(solver.wins.keys).not_to include("E")
      expect(solver.wins.keys.select { |turn| turn.is_a?(Integer) }.min).to eq(15)
      expect(solver.wins[15]).to eq(deck[:earliest_turn_count])
    end
  end
end

describe "weighted solver traversal" do
  it "preserves permutation totals when a game ends before the deck is drawn" do
    algo = Proc.new do |game_state|
      game_state.opponent_life = 0 if game_state.turn == 1
    end
    results = [true, false].map do |memoize|
      solver = MTG::Solver.new(
        decklist: {
          MTG::Solver::Card.land => 2,
          MTG::Solver::Card.bolt => 2,
        },
        algo: algo,
        opponent_life: 1,
        initial_draw: 1,
        memoize: memoize,
      )
      solver.solve
      solver.wins
    end

    expect(results[0]).to eq(results[1])
    expect(results[0]).to eq({1 => 24})
  end
end

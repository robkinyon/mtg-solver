describe "starting hand" do
  it "handles draw 1 from 1/1" do
    solver = MTG::Solver.new(
      decklist: {
        MTG::Solver::Card.land => 1,
        MTG::Solver::Card.bolt => 1,
      },
      algo: "fake",
      initial_draw: 1,
    )
    expect(solver.starting_hand).to match_array([
      {
        MTG::Solver::Card.land => 1,
      },
      {
        MTG::Solver::Card.bolt => 1,
      },
    ])
  end
end

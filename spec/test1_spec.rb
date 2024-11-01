describe "basic" do
  context "Life: 1, Draw: 1" do
    it "handles L/B" do
      deck = [
        MTG::Solver::Card.land,
        MTG::Solver::Card.bolt,
      ]
      solver = MTG::Solver.new(
        deck: deck,
        initial_life: 1,
        initial_draw: 1,
      )
      solver.solve
      wins = {1 => 2}
      expect(solver.wins).to eq(wins)
    end
    it "handles B/L" do
      deck = [
        MTG::Solver::Card.bolt,
        MTG::Solver::Card.land,
      ]
      solver = MTG::Solver.new(
        deck: deck,
        initial_life: 1,
        initial_draw: 1,
      )
      solver.solve
      wins = {1 => 2}
      expect(solver.wins).to eq(wins)
    end
    it "handles LLB" do
      deck = [
        MTG::Solver::Card.land,
        MTG::Solver::Card.land,
        MTG::Solver::Card.bolt,
      ]
      solver = MTG::Solver.new(
        deck: deck,
        initial_life: 1,
        initial_draw: 1,
      )
      solver.solve
      wins = {1 => 2, 2 => 1}
      expect(solver.wins).to eq(wins)
    end
    it "handles LBB" do
      deck = [
        MTG::Solver::Card.land,
        MTG::Solver::Card.bolt,
        MTG::Solver::Card.bolt,
      ]
      solver = MTG::Solver.new(
        deck: deck,
        initial_life: 1,
        initial_draw: 1,
      )
      solver.solve
      wins = {1 => 2, 2 => 1}
      expect(solver.wins).to eq(wins)
    end
  end
end

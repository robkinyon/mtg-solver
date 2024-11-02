describe "basic" do
  context "Life: 1, Draw: 1" do
    before(:each) {
      @conditions = {
        initial_life: 1,
        initial_draw: 1,
      }
    }
    it "handles L/B" do
      run_test(
        deck: [
          MTG::Solver::Card.land,
          MTG::Solver::Card.bolt,
        ],
        conditions: @conditions,
        expected: {1 => 2},
      )
    end
    it "handles LLB" do
      run_test(
        deck: [
          MTG::Solver::Card.land,
          MTG::Solver::Card.land,
          MTG::Solver::Card.bolt,
        ],
        conditions: @conditions,
        expected: {1 => 2, 2 => 1},
      )
    end
    it "handles LBB" do
      run_test(
        deck: [
          MTG::Solver::Card.land,
          MTG::Solver::Card.bolt,
          MTG::Solver::Card.bolt,
        ],
        conditions: @conditions,
        expected: {1 => 2, 2 => 1},
      )
    end
  end
end

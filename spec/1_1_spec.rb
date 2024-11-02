describe "basic" do
  context "Life: 1, Initial Draw: 1" do
    before(:all) {
      @conditions = {
        initial_life: 1,
        initial_draw: 1,
      }
    }
    it "handles L/B" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 1,
          MTG::Solver::Card.bolt => 1,
        },
        conditions: @conditions,
        expected: {1 => 2},
      )
    end
    it "handles LLB" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 2,
          MTG::Solver::Card.bolt => 1,
        },
        conditions: @conditions,
        expected: {1 => 2, 2 => 1},
      )
    end
    it "handles LBB" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 1,
          MTG::Solver::Card.bolt => 2,
        },
        conditions: @conditions,
        expected: {1 => 2, 2 => 1},
      )
    end
  end
end

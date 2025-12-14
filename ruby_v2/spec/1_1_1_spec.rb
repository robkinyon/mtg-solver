describe "basic" do
  context "Life: 1, Initial Draw: 1, Bolt Dmg 1" do
    before(:all) {
      @conditions = {
        opponent_life: 1,
        initial_draw: 1,
        dmg_per_bolt: 1,
      }
    }
    describe "2-card" do
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
    end
    describe "3-card" do
      it "handles LLB" do
        run_test(
          deck: {
            MTG::Solver::Card.land => 2,
            MTG::Solver::Card.bolt => 1,
          },
          conditions: @conditions,
          expected: {1 => 4, 2 => 2},
        )
      end
      it "handles LBB" do
        run_test(
          deck: {
            MTG::Solver::Card.land => 1,
            MTG::Solver::Card.bolt => 2,
          },
          conditions: @conditions,
          expected: {1 => 4, 2 => 2},
        )
      end
    end
    describe "4-card" do
      it "handles LLLB/1" do
        run_test(
          deck: {
            MTG::Solver::Card.land => 3,
            MTG::Solver::Card.bolt => 1,
          },
          conditions: @conditions,
          expected: {1 => 12, 2 => 6, 3 => 6},
        )
      end
      it "handles LLBB/1" do
        run_test(
          deck: {
            MTG::Solver::Card.land => 2,
            MTG::Solver::Card.bolt => 2,
          },
          conditions: @conditions,
          expected: {1 => 16, 2 => 8},
        )
      end
    end
  end
end

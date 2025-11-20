# This test is where we ensure handling of deck exhaustion.

describe "basic" do
  context "Life: 2, Initial Draw: 1, Bolt Dmg 1" do
    before(:all) {
      @conditions = {
        opponent_life: 2,
        initial_draw: 1,
        dmg_per_bolt: 1,
      }
    }
    it "handles L/B" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 1,
          MTG::Solver::Card.bolt => 1,
        },
        conditions: @conditions,
        expected: {"E" => 2},
        permutations: 2,
      )
    end
    it "handles LLB" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 2,
          MTG::Solver::Card.bolt => 1,
        },
        conditions: @conditions,
        expected: {"E" => 6},
        permutations: 6,
      )
    end
    it "handles LBB" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 1,
          MTG::Solver::Card.bolt => 2,
        },
        conditions: @conditions,
        expected: {"E" => 2, 2 => 4},
        permutations: 6,
      )
    end
  end
end

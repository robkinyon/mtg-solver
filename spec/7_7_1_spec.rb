describe "basic" do
  context "Life: 7, Initial Draw: 7, Bolt Dmg: 1" do
    before(:all) {
      @conditions = {
        initial_life: 7,
        initial_draw: 7,
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
      )
    end
    it "handles 7L/7B" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 7,
          MTG::Solver::Card.bolt => 7,
        },
        conditions: @conditions,
        expected: {4 => 330, 5 => 462, 6 => 924, 7 => 1716},
      )
    end
  end
end

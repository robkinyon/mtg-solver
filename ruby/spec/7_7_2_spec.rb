describe "basic" do
  context "Life: 7, Initial Draw: 7, Bolt Dmg 2" do
    before(:all) {
      @conditions = {
        initial_life: 7,
        initial_draw: 7,
        dmg_per_bolt: 2,
      }
    }
    it "handles 7L/7B" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 7,
          MTG::Solver::Card.bolt => 7,
        },
        conditions: @conditions,
        expected: {3 => 3312, 4 => 120},
        calls: 1584,
        total: 3432,
        permutations: 87178291200,
      )
    end
  end
end

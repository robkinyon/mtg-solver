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
        calls: 2,
        total: 2,
        permutations: 2,
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
        calls: 3432,
        total: 3432,
        permutations: 87178291200,
      )
    end
    it "handles 8L/12B" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 8,
          MTG::Solver::Card.bolt => 12,
        },
        conditions: @conditions,
        expected: {
         4 => 65268,
         5 => 27482,
         6 => 19845,
         7 => 10360,
         8 => 3014,
         9 => 1,
        },
        calls: 10443,
        total: 125970,
        permutations: 2432902008176640000,
      )
    end
#    it "handles 10L/15B" do
#      run_test(
#        deck: {
#          MTG::Solver::Card.land => 10,
#          MTG::Solver::Card.bolt => 15,
#        },
#        conditions: @conditions,
#        expected: {
#          4 => 1661946,
#          5 => 650793,
#          6 => 478005,
#          7 => 288167,
#          8 => 136345,
#          9 => 45400,
#          10 => 8090,
#          11 => 13,
#          12 => 1,
#        },
#        calls: 31568,
#        total: 3432,
#        permutations: 2,
#      )
#    end
#    it "handles 12L/18B" do
#      run_test(
#        deck: {
#          MTG::Solver::Card.land => 12,
#          MTG::Solver::Card.bolt => 18,
#        },
#        conditions: @conditions,
#        expected: {
#         4 => 43417660,
#         5 => 16414112,
#         6 => 12145276,
#         7 => 7716046,
#         8 => 4154943,
#         9 => 1843205,
#         10 => 631995,
#         11 => 150735,
#         12 => 19126,
#         13 => 111,
#         14 => 15,
#         15 => 1,
#        },
#        calls: 82976,
#        total: 3432,
#        permutations: 2,
#      )
#    end
  end
end

describe "basic" do
  context "Life: 7, Initial Draw: 7, Bolt Dmg: 1" do
    before(:all) {
      @conditions = {
        opponent_life: 7,
        initial_draw: 7,
        dmg_per_bolt: 1,
      }
    }
    xit "handles L/B" do
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
    it "handles 7L/7B" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 7,
          MTG::Solver::Card.bolt => 7,
        },
        conditions: @conditions,
        expected: {
          4 => 8382528000,
          5 => 11735539200,
          6 => 23471078400,
          7 => 43589145600,
        },
      )
    end
    it "handles 8L/8B" do
      run_test(
        deck: {
          MTG::Solver::Card.land => 8,
          MTG::Solver::Card.bolt => 8,
        },
        conditions: @conditions,
        expected: {
          4 => 2949024153600,
          5 => 3005923737600,
          6 => 4506447052800,
          7 => 5579410636800,
          8 => 4881984307200,
        },
      )
    end
#    xit "handles 10L/15B" do
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
#        permutations: 2,
#      )
#    end
#    xit "handles 12L/18B" do
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
#        permutations: 2,
#      )
#    end
  end
end

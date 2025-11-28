describe "starting hand" do
  it "handles draw 1 from 1/1" do
    starting_hand_test(
      decklist: {
        MTG::Solver::Card.land => 1,
        MTG::Solver::Card.bolt => 1,
      },
      initial_draw: 1,
      expected: [
        [{
          MTG::Solver::Card.land => 1,
        }, 1],
        [{
          MTG::Solver::Card.bolt => 1,
        }, 1],
      ],
    )
  end

  it "handles draw 2 from 2/2" do
    starting_hand_test(
      decklist: {
        MTG::Solver::Card.land => 2,
        MTG::Solver::Card.bolt => 2,
      },
      initial_draw: 2,
      expected: [
        [{
          MTG::Solver::Card.land => 2,
        }, 2],
        [{
          MTG::Solver::Card.land => 1,
          MTG::Solver::Card.bolt => 1,
        }, 8],
        [{
          MTG::Solver::Card.bolt => 2,
        }, 2],
      ],
    )
  end

  it "handles draw 2 from 3/3" do
    starting_hand_test(
      decklist: {
        MTG::Solver::Card.land => 3,
        MTG::Solver::Card.bolt => 3,
      },
      initial_draw: 2,
      expected: [
        [{
          MTG::Solver::Card.land => 2,
        }, 6],
        [{
          MTG::Solver::Card.land => 1,
          MTG::Solver::Card.bolt => 1,
        }, 18],
        [{
          MTG::Solver::Card.bolt => 2,
        }, 6],
      ],
    )
  end
end

describe "Math Assumptions" do
  context "math" do
    before(:all) do
      @solver = MTG::Solver.new(
        decklist: {},
        algo: "fake",
      )
    end
    describe "factorial" do
      it "factorials 5" do
        expect(@solver.factorial(5)).to eq(120)
      end
    end
    describe "binomial_coefficient" do
      it "5 over 2" do
        expect(@solver.binomial_coefficient(5, 2)).to eq(10)
      end
    end
    describe "multivariate hypergeometric distribution" do
    end
  end

  deck_permutations = [
    "LB/1",
    "LLB/1", "LLB/2",
    "LLLB/1", #"LLLB/2", "LLLB/3",
    #"LLBB/1", "LLBB/2", "LLBB/3",
    #"LLLLB/1", "LLLLB/2", "LLLLB/3", "LLLLB/4",
    #"LLLBB/1", "LLLBB/2", "LLLBB/3", "LLLBB/4",
    #"LLLLLB/1", "LLLLLB/2", "LLLLLB/3", "LLLLLB/4", "LLLLLB/5",
    #"LLLLBB/1", "LLLLBB/2", "LLLLBB/3", "LLLLBB/4", "LLLLBB/5",
    #"LLLBBB/1", "LLLBBB/2", "LLLBBB/3", "LLLBBB/4", "LLLBBB/5",
  ]

  context "sum(hand probability * remaining probabilities) == permutations" do
    def testit(decklist:, initial_draw:)
      solver = MTG::Solver.new(
        decklist: decklist,
        algo: "fake",
        initial_draw: initial_draw,
      )
      permutations = solver.factorial(solver.decksize)
      calculated_permutations = 0
      solver.starting_hand do |hand, p|
        this_decklist = solver.decklist.clone
        hand.each {|card, count| this_decklist[card] -= count}
        rp = solver.factorial(this_decklist.values.sum)
        calculated_permutations += p * rp
      end
      expect(calculated_permutations).to eq(permutations)
    end

    deck_permutations.each do |decklist|
      match = decklist.match(%r{(L+)(B+)/(\d+)})
      it "handles #{decklist}" do
        testit(
          decklist: {
            MTG::Solver::Card.land => match[1].length,
            MTG::Solver::Card.bolt => match[2].length,
          },
          initial_draw: match[3].to_i,
        )
      end
    end
  end
  context "remaining_probabilities at each level are correct" do
    def testit(decklist:, initial_draw:, win_at:)
      algo = Proc.new do |g|
        g.opponent_life = 0 if g.turn == win_at
      end
      solver = MTG::Solver.new(
        decklist: decklist,
        algo: algo,
        initial_draw: initial_draw,
      )
      permutations = solver.factorial(solver.decksize)
      solver.solve

      expect(solver.wins.values.sum).to eq(permutations)
    end

    deck_permutations.each do |decklist|
      match = decklist.match(%r{(L+)(B+)/(\d+)})
      num_land = match[1].length
      num_bolt = match[2].length
      initial_draw = match[3].to_i
      (1..((num_land+num_bolt)-initial_draw)+1).each do |win_at|
        it "handles #{decklist} winning at #{win_at}" do
          testit(
            decklist: {
              MTG::Solver::Card.land => num_land,
              MTG::Solver::Card.bolt => num_bolt,
            },
            initial_draw: initial_draw,
            win_at: win_at,
          )
        end
      end
    end
  end
end

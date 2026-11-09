mod solver;

fn main() {
    use solver::{Objective, Solver};

    if std::env::args().any(|arg| arg == "--optimize") {
        for objective in [Objective::Fastest, Objective::AverageKillTurn] {
            for result in Solver::optimize(60, objective) {
                println!(
                    "Deck M/B/Mox/Lotus={:?}, earliest={:?} at {:.4}%, average={:?}, win={:.4}%, total={:.6}",
                    result.deck,
                    result.earliest_turn,
                    result.earliest_turn_probability * 100.0,
                    result.average_kill_turn,
                    result.win_probability * 100.0,
                    result.distribution.iter().sum::<f64>()
                );
            }
        }
    } else {
        let deck = [18, 38, 2, 2];
        let fastest = Solver::new(deck).solve(Objective::Fastest);
        let average = Solver::new(deck).solve(Objective::AverageKillTurn);
        println!("Deck M/B/Mox/Lotus={deck:?}");
        println!(
            "Fastest: turn {:?}, probability {:.4}%, total={:.6}",
            fastest.earliest_turn,
            fastest.earliest_turn_probability * 100.0,
            fastest.distribution.iter().sum::<f64>()
        );
        println!(
            "Average kill turn: {:?}, win probability {:.4}%, total={:.6}",
            average.average_kill_turn,
            average.win_probability * 100.0,
            average.distribution.iter().sum::<f64>()
        );
    }
}

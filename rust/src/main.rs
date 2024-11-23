mod solver;

fn main() {
    use solver::Solver;
    let s = Solver {
        initial_life: 20,
        initial_draw: 7,
    };
    println!("Hello, world! Solution is {}", s.solve());
}

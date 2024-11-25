mod solver;

fn main() {
    use solver::Solver;
    let s = Solver::new();
    println!("Hello, world! Solution is {}", s.solve());
}

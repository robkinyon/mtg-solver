mod game;

pub struct Solver {
    initial_life: u8,
    initial_draw: u8,
}

use game::Game;
impl Solver {
    pub fn new() -> Self {
        Self {
            initial_life: 20,
            initial_draw: 7,
        }
    }
    pub fn solve(&self) -> u8 {
        let mut g = Game::new(self.initial_draw, self.initial_life);
        g.run()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn solver_solves() {
        let s = Solver::new();
        assert_eq!(s.solve(), 6);
    }
}

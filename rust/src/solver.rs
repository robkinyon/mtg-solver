mod game;

pub struct Solver {
    initial_life: u8,
    initial_draw: u8,
}

impl Solver {
    pub fn new() -> Self {
        Self {
            initial_life: 20,
            initial_draw: 7,
        }
    }
    pub fn solve(&self) -> u8 {
        use game::Game;
        let g = Game::new();
        g.value() + self.initial_life * self.initial_draw
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn solver_solves() {
        let s = Solver::new();
        assert_eq!(s.solve(), 155);
    }
}

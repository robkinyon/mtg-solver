pub struct Solver {
    pub initial_life: u8,
    pub initial_draw: u8,
}

impl Solver {
    pub fn solve(&self) -> u8 {
        self.initial_life * self.initial_draw
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn solver_solves() {
        let s = Solver {
            initial_life: 20,
            initial_draw: 7,
        };
        assert_eq!(s.solve(), 140);
    }
}

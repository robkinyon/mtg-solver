//use itertools::Itertools;
use std::iter;

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
    pub fn solve(&self) -> Vec<i32> {
        // Mountain: 1
        // Bolt: 2
        let initial_deck: Vec<u8> = vec![
            1, // 1, 1, 1, 1, 1, 1, // Extra cards
            2, 2, 2, 2, 2, 2, 2, // Draw 7 bolts
            1, 1, 1, 1, 1, 1, 1, // Initial hand
        ];
        println!("{initial_deck:?}");
        let mut wins: Vec<_> = iter::repeat(0).take(8).collect();
        // for deck in initial_deck
        //     .iter()
        //     .cloned()
        //     .permutations(initial_deck.len())
        //     .unique()
        // {
        let deck = initial_deck;
        print!("{deck:?}");
        // Has to be usize in order to index into wins
        let turn = self.find_winning_turn(deck) as usize;
        // deck cannot be used here because ownership was transferred
        println!("->{turn:?}");
        wins[turn] += 1;
        // }
        // println!("Done");
        wins
    }

    fn find_winning_turn(&self, deck: Vec<u8>) -> u8 {
        let mut g = Game::new(self.initial_draw, self.initial_life, deck);
        g.run().unwrap_or(0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn solver_solves() {
        let s = Solver::new();
        assert_eq!(s.solve(), [0, 0, 0, 0, 0, 0, 0, 1]);
    }
}

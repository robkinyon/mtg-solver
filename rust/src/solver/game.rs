//#[derive(Debug)]
pub struct Game {
    deck: Vec<u8>,
    hand: Vec<u8>,
    in_play: Vec<u8>,
    graveyard: Vec<u8>,
    // out_of_play: Vec<u8>,
    initial_draw: u8,
    opponent_life: i8,
}

#[derive(Debug)]
pub struct DeckExhaustion;

impl Game {
    pub fn new(initial_draw: u8, initial_life: u8, deck: Vec<u8>) -> Self {
        Self {
            deck,
            hand: Vec::new(),
            in_play: Vec::new(),
            graveyard: Vec::new(),
            // out_of_play: Vec::new(),
            initial_draw,
            opponent_life: initial_life as i8,
            /*
            algo: |game, turn| {
                game.opponent_life - turn
            },
            */
        }
    }

    fn algo(&mut self) {
        self.play_to_in_play(1); // 1 == Mountain
        let mut mana: u8 = self.in_play.len() as u8;
        while mana > 0 {
            // 2 == Bolt
            if self.play_to_graveyard(2) {
                mana -= 1_u8; // Cost of a bolt
                self.opponent_life -= 3_i8; // Dmg of a bolt
            } else {
                break;
            }
        }
    }

    // In order to use a simple Vec instead of a Deque, the deck is stored
    // in reverse. That allows us to use push/pop semantics instead of shift.
    fn draw(&mut self, num: u8) -> Result<(), DeckExhaustion> {
        for _n in 0..num {
            if let Some(card) = self.deck.pop() {
                self.hand.push(card);
            } else {
                return Err(DeckExhaustion);
            }
        }
        Ok(())
    }

    fn play_to_graveyard(&mut self, card: u8) -> bool {
        let idx = self.hand.iter().position(|&c| c == card);
        match idx {
            Some(i) => {
                self.graveyard.push(self.hand.remove(i));
                true
            }
            None => false,
        }
    }

    fn play_to_in_play(&mut self, card: u8) -> bool {
        let idx = self.hand.iter().position(|&c| c == card);
        match idx {
            Some(i) => {
                self.in_play.push(self.hand.remove(i));
                true
            }
            None => false,
        }
    }

    pub fn run(&mut self) -> Result<u8, DeckExhaustion> {
        let mut turn: u8 = 0;
        self.draw(self.initial_draw)?;
        while self.opponent_life > 0 {
            // println!("Turn: {turn} {self:?}");
            turn += 1;
            self.draw(1)?;
            self.algo();
        }
        Ok(turn)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn game_constructor() {
        let mut g = Game::new(
            7,
            20,
            vec![
                1, 1, 1, 1, 1, 1, 1, // Initial hand
                2, 2, 2, 2, 2, 2, 2, // Draw 7 bolts
                1, 1, 1, 1, 1, 1, // Extra cards
            ],
        );
        assert_eq!(g.run().unwrap(), 6);
    }
}

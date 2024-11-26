pub struct Game {
    deck: Vec<u8>,
    hand: Vec<u8>,
    // in_play: Vec<u8>,
    // graveyard: Vec<u8>,
    // out_of_play: Vec<u8>,
    initial_draw: u8,
    opponent_life: i8,
}

impl Game {
    pub fn new(initial_draw: u8, initial_life: u8) -> Self {
        Self {
            deck: vec![
                1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            ],
            hand: Vec::new(),
            // in_play: Vec::new(),
            // graveyard: Vec::new(),
            // out_of_play: Vec::new(),
            initial_draw: initial_draw,
            opponent_life: initial_life as i8,
            /*
            algo: |game, turn| {
                game.opponent_life - turn
            },
            */
        }
    }

    fn algo(&mut self, turn: u8) {
        self.opponent_life = self.opponent_life - turn as i8;
    }

    fn draw(&mut self, num: u8) {
        // Need to propagate deck exhaustion
        for _n in 1..num {
            self.hand.push(self.deck.pop().unwrap());
        }
    }

    pub fn run(&mut self) -> u8 {
        let mut turn: u8 = 0;
        self.draw(self.initial_draw);
        while self.opponent_life > 0 {
            turn += 1;
            self.draw(1);
            self.algo(turn);
        }
        turn
    }
}

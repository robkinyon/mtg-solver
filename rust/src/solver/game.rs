pub struct Game {
    deck: u8,
    hand: u8,
    in_play: u8,
    graveyard: u8,
    out_of_play: u8,
}

impl Game {
    pub fn new() -> Self {
        Self {
            deck: 1,
            hand: 2,
            in_play: 3,
            graveyard: 4,
            out_of_play: 5,
        }
    }

    pub fn value(&self) -> u8 {
        self.deck + self.hand + self.in_play + self.graveyard + self.out_of_play
    }
}

use std::collections::HashMap;

const MOUNTAIN: usize = 0;
const BOLT: usize = 1;
const MOX_RUBY: usize = 2;
const BLACK_LOTUS: usize = 3;
const CARD_TYPES: usize = 4;

#[derive(Clone, Copy)]
pub enum Objective {
    Fastest,
    AverageKillTurn,
}

#[derive(Clone, Debug)]
pub struct Result {
    pub deck: [usize; CARD_TYPES],
    pub distribution: Vec<f64>,
    pub earliest_turn: Option<usize>,
    pub earliest_turn_probability: f64,
    pub average_kill_turn: Option<f64>,
    pub win_probability: f64,
}

#[derive(Clone, Eq, Hash, PartialEq)]
struct State {
    remaining: [usize; CARD_TYPES],
    hand: [usize; CARD_TYPES],
    mountains: usize,
    mox: usize,
    lotus: usize,
    life: i16,
    turn: usize,
}

pub struct Solver {
    deck: [usize; CARD_TYPES],
    initial_life: i16,
    initial_draw: usize,
}

impl Solver {
    pub fn new(deck: [usize; CARD_TYPES]) -> Self {
        Self {
            deck,
            initial_life: 20,
            initial_draw: 7,
        }
    }

    pub fn with_rules(deck: [usize; CARD_TYPES], initial_life: i16, initial_draw: usize) -> Self {
        Self {
            deck,
            initial_life,
            initial_draw,
        }
    }

    pub fn solve(&self, objective: Objective) -> Result {
        let deck_size = self.deck.iter().sum::<usize>();
        assert!(self.initial_draw <= deck_size);

        let distribution = match objective {
            Objective::Fastest => self.evaluate(None),
            Objective::AverageKillTurn => {
                let mut lambda = 0.0;
                let mut distribution = self.evaluate(Some(lambda));
                for _ in 0..100 {
                    let win_probability = Self::win_probability(&distribution, deck_size);
                    if win_probability == 0.0 {
                        break;
                    }
                    let next_lambda =
                        Self::weighted_turns(&distribution, deck_size) / win_probability;
                    if (next_lambda - lambda).abs() < 1e-12 {
                        break;
                    }
                    lambda = next_lambda;
                    distribution = self.evaluate(Some(lambda));
                }
                distribution
            }
        };

        let win_probability = Self::win_probability(&distribution, deck_size);
        let earliest_turn = (1..=deck_size).find(|turn| distribution[*turn] > 1e-14);
        let average_kill_turn = if win_probability == 0.0 {
            None
        } else {
            Some(Self::weighted_turns(&distribution, deck_size) / win_probability)
        };

        Result {
            deck: self.deck,
            earliest_turn,
            earliest_turn_probability: earliest_turn.map_or(0.0, |turn| distribution[turn]),
            average_kill_turn,
            win_probability,
            distribution,
        }
    }

    pub fn optimize(size: usize, objective: Objective) -> Vec<Result> {
        let mut results = Vec::new();
        // With unrestricted copies, Mox Ruby strictly dominates a Mountain.
        for bolts in 0..=size {
            for mox in 0..=(size - bolts) {
                let lotus = size - bolts - mox;
                results.push(
                    Solver::with_rules([0, bolts, mox, lotus], 20, 7.min(size)).solve(objective),
                );
            }
        }

        match objective {
            Objective::Fastest => {
                let earliest = results.iter().filter_map(|r| r.earliest_turn).min();
                if let Some(earliest) = earliest {
                    let best_probability = results
                        .iter()
                        .filter(|r| r.earliest_turn == Some(earliest))
                        .map(|r| r.earliest_turn_probability)
                        .fold(0.0_f64, f64::max);
                    results.retain(|r| {
                        r.earliest_turn == Some(earliest)
                            && (r.earliest_turn_probability - best_probability).abs() < 1e-12
                    });
                }
            }
            Objective::AverageKillTurn => {
                let best_average = results
                    .iter()
                    .filter_map(|r| r.average_kill_turn)
                    .fold(f64::INFINITY, f64::min);
                results.retain(|r| {
                    r.average_kill_turn
                        .is_some_and(|average| (average - best_average).abs() < 1e-12)
                });
            }
        }
        results
    }

    fn evaluate(&self, lambda: Option<f64>) -> Vec<f64> {
        let deck_size = self.deck.iter().sum::<usize>();
        let mut evaluator = Evaluator {
            deck_size,
            lambda,
            memo: HashMap::new(),
        };
        let mut distribution = vec![0.0; deck_size + 2];
        let mut hand = [0; CARD_TYPES];
        let denominator = combination(deck_size, self.initial_draw) as f64;
        self.enumerate_hands(
            0,
            self.initial_draw,
            &mut hand,
            denominator,
            &mut evaluator,
            &mut distribution,
        );
        distribution
    }

    fn enumerate_hands(
        &self,
        index: usize,
        cards_left: usize,
        hand: &mut [usize; CARD_TYPES],
        denominator: f64,
        evaluator: &mut Evaluator,
        distribution: &mut [f64],
    ) {
        if index == CARD_TYPES {
            if cards_left == 0 {
                let weight = hand
                    .iter()
                    .enumerate()
                    .map(|(i, count)| combination(self.deck[i], *count) as f64)
                    .product::<f64>()
                    / denominator;
                let state = State {
                    remaining: std::array::from_fn(|i| self.deck[i] - hand[i]),
                    hand: *hand,
                    mountains: 0,
                    mox: 0,
                    lotus: 0,
                    life: self.initial_life,
                    turn: 0,
                };
                let outcomes = evaluator.draw_for_turn(state);
                for (total, outcome) in distribution.iter_mut().zip(outcomes) {
                    *total += weight * outcome;
                }
            }
            return;
        }

        let max_count = self.deck[index].min(cards_left);
        let remaining_capacity = self.deck[index + 1..].iter().sum::<usize>();
        let min_count = cards_left.saturating_sub(remaining_capacity);
        for count in min_count..=max_count {
            hand[index] = count;
            self.enumerate_hands(
                index + 1,
                cards_left - count,
                hand,
                denominator,
                evaluator,
                distribution,
            );
        }
        hand[index] = 0;
    }

    fn win_probability(distribution: &[f64], deck_size: usize) -> f64 {
        distribution[1..=deck_size].iter().sum()
    }

    fn weighted_turns(distribution: &[f64], deck_size: usize) -> f64 {
        (1..=deck_size)
            .map(|turn| turn as f64 * distribution[turn])
            .sum()
    }
}

struct Evaluator {
    deck_size: usize,
    lambda: Option<f64>,
    memo: HashMap<State, Vec<f64>>,
}

impl Evaluator {
    fn draw_for_turn(&mut self, state: State) -> Vec<f64> {
        if let Some(cached) = self.memo.get(&state) {
            return cached.clone();
        }

        let remaining_total = state.remaining.iter().sum::<usize>();
        if remaining_total == 0 {
            let mut outcomes = vec![0.0; self.deck_size + 2];
            outcomes[self.deck_size + 1] = 1.0;
            return outcomes;
        }

        let mut outcomes = vec![0.0; self.deck_size + 2];
        for card in 0..CARD_TYPES {
            let count = state.remaining[card];
            if count == 0 {
                continue;
            }
            let mut next = state.clone();
            next.remaining[card] -= 1;
            next.hand[card] += 1;
            next.turn += 1;
            let branch = self.play_turn(next);
            let probability = count as f64 / remaining_total as f64;
            for (total, result) in outcomes.iter_mut().zip(branch) {
                *total += probability * result;
            }
        }

        self.memo.insert(state, outcomes.clone());
        outcomes
    }

    fn play_turn(&mut self, mut state: State) -> Vec<f64> {
        if state.hand[MOUNTAIN] > 0 {
            state.hand[MOUNTAIN] -= 1;
            state.mountains += 1;
        }

        state.mox += state.hand[MOX_RUBY];
        state.hand[MOX_RUBY] = 0;
        state.lotus += state.hand[BLACK_LOTUS];
        state.hand[BLACK_LOTUS] = 0;

        let regular_mana = state.mountains + state.mox;
        let lethal_bolts = ((state.life.max(0) as usize) + 2) / 3;
        let max_bolts = state.hand[BOLT]
            .min(regular_mana + 3 * state.lotus)
            .min(lethal_bolts);
        let regular_bolts = state.hand[BOLT].min(regular_mana);
        let mut lotus_options = vec![0];
        let mut last_lotus_count = 0;
        for bolts_cast in (regular_bolts + 1)..=max_bolts {
            let lotus_used = (bolts_cast - regular_mana).div_ceil(3);
            if lotus_used != last_lotus_count {
                lotus_options.push(lotus_used);
                last_lotus_count = lotus_used;
            }
        }

        let mut options = Vec::with_capacity(lotus_options.len());
        for lotus_used in lotus_options {
            let bolts_cast = state.hand[BOLT].min(regular_mana + 3 * lotus_used);
            let mut next = state.clone();
            next.lotus -= lotus_used;
            next.hand[BOLT] -= bolts_cast;
            next.life -= 3 * bolts_cast as i16;

            if next.life <= 0 {
                let mut result = vec![0.0; self.deck_size + 2];
                result[next.turn] = 1.0;
                options.push(result);
            } else {
                options.push(self.draw_for_turn(next));
            }
        }
        self.choose(options)
    }

    fn choose(&self, mut options: Vec<Vec<f64>>) -> Vec<f64> {
        let mut best = options.remove(0);
        for candidate in options {
            let better = if let Some(lambda) = self.lambda {
                self.score(&candidate, lambda) < self.score(&best, lambda) - 1e-14
            } else {
                self.faster(&candidate, &best)
            };
            if better {
                best = candidate;
            }
        }
        best
    }

    fn faster(&self, candidate: &[f64], incumbent: &[f64]) -> bool {
        for turn in 1..=self.deck_size {
            let difference = candidate[turn] - incumbent[turn];
            if difference.abs() > 1e-14 {
                return difference > 0.0;
            }
        }
        false
    }

    fn score(&self, distribution: &[f64], lambda: f64) -> f64 {
        (1..=self.deck_size)
            .map(|turn| distribution[turn] * (turn as f64 - lambda))
            .sum()
    }
}

fn combination(n: usize, k: usize) -> u128 {
    if k > n {
        return 0;
    }
    let k = k.min(n - k);
    (0..k).fold(1_u128, |value, i| value * (n - i) as u128 / (i + 1) as u128)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn counts_all_small_deck_orders() {
        let result = Solver::with_rules([2, 2, 0, 0], 3, 1).solve(Objective::Fastest);
        let total: f64 = result.distribution.iter().sum();
        assert!((total - 1.0).abs() < 1e-12);
        assert_eq!(result.earliest_turn, Some(1));
    }

    #[test]
    fn mox_and_lotus_are_played_as_red_mana_sources() {
        let result = Solver::with_rules([0, 3, 1, 1], 6, 4).solve(Objective::Fastest);
        assert_eq!(result.earliest_turn, Some(1));
        assert!((result.earliest_turn_probability - 1.0).abs() < 1e-12);
    }

    #[test]
    fn mox_ruby_provides_one_mana_each_turn() {
        let result = Solver::with_rules([0, 1, 1, 0], 3, 1).solve(Objective::Fastest);
        assert_eq!(result.earliest_turn, Some(1));
        assert!((result.earliest_turn_probability - 1.0).abs() < 1e-12);
    }

    #[test]
    fn black_lotus_can_pay_for_three_bolts() {
        let result = Solver::with_rules([0, 4, 0, 1], 9, 4).solve(Objective::Fastest);
        assert_eq!(result.earliest_turn, Some(1));
        assert!((result.earliest_turn_probability - 1.0).abs() < 1e-12);
    }

    #[test]
    fn sixty_card_distributions_are_normalized() {
        let solver = Solver::new([18, 38, 2, 2]);
        for objective in [Objective::Fastest, Objective::AverageKillTurn] {
            let result = solver.solve(objective);
            let total = result.distribution.iter().sum::<f64>();
            assert!((total - 1.0).abs() < 1e-12);
        }
    }

    #[test]
    fn optimizer_returns_all_ties_for_small_decks() {
        let results = Solver::optimize(3, Objective::Fastest);
        assert!(!results.is_empty());
        assert!(results
            .iter()
            .all(|result| result.earliest_turn == results[0].earliest_turn));
    }
}

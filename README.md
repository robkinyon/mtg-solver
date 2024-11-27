# mtg-solver

This is my personal project to create a goldfish solver for the game Magic, the
Gathering. The idea is that a user provides:

* a deck (list of cards with numbers of each one)
* a function that implements a turn
* play/draw and mulligan

Given those two things, the solver will find every unique combination of cards
and play a game, calling the function for each turn. The opponent will be a
goldfish - a player who has a deck of N colorless basic land who will draw a
card, play a land, then end the turn.

The output will be a histogram of wins-by-turn. One of those turns will be "E",
for "End of deck". The sum of these numbers will be the total number of unique
combinations for the deck specification.

Part of what the solver will do is reduce the number of games that need to be
played to the absolute minimum to ensure all combinations are exercised. The
shortcuts taken are:

* If a deck layout wins on turn 4, there's no reason to shuffle the cards that
weren't seen. (implemented)
* There's no reason to rerun a combination that only differs by the order of the
cards in the initial hand.

# Implementations

I'm doing all this development in Termux on my Samsung S20+ using DeX via a
portable touchscreen monitor and bluetooth keyboard (no mouse).

## Ruby

This is the implementation I started with because it was quickest to sketch out
the details. It is not performant enough on my S20+.

## Rust

I'm using this to learn Rust and (hopefully) it will be performant enough on my
S20+.

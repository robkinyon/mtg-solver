# Test Debugging Summary

## Fix Applied ✅
**Removed erroneous `factorial(unique_cards.length)` multiplier from `hand_probability()`**

- **Status**: FIXED - All starting_hand tests pass
- **Impact**: Corrected initial hand counts from 2x inflation
- **Change**: [lib/mtg/solver.rb](lib/mtg/solver.rb#L85-L93) removed the third multiplication factor

## Remaining Issue ⚠️
**6 tests still failing** - Game tree traversal undercounts permutations by ~2x

### Affected Tests
- basiclife: 1 / Initial Draw: 1 / Bolt Dmg 1
  - LLBB/1: expected {1=>16, 2=>8}, got {1=>8, 2=>8}
  - LLLB/1: expected {1=>12, 2=>6, 3=>6}, got {1=>12, 2=>6, 3=>3}
- Math Assumptions: multiple tests where `wins.values.sum` is roughly half expected

### Root Cause
The `odom` (odometer) game tree traversal algorithm in `solve()` doesn't properly explore all distinct orderings of remaining deck cards.

**Problem**: 
- Initializes odoms with `unique_cards()` which returns card TYPES [L, B]
- Shifts cards sequentially, which explores only 1 branch at each level
- Backtracking logic only explores descendants of the first choice, not sibling choices
- Result: ~50% of game paths are never explored

**Example**: For remaining {L=>1, B=>2}, there are 3 distinct orderings:
- L,B,B ✓ explored
- B,L,B ✗ NOT explored  
- B,B,L ✗ NOT explored

### Fix Required
Rewrite the odom initialization to use deduplicated permutation enumeration instead of simple card-type shifting.

**Recommended Approach**:
Use the existing `unique_permutation()` method from [ruby_v1/unique_permutation.rb](#unique_permutation-background) or implement a similar algorithm to generate all distinct orderings at each turn.

```ruby
# Current (broken):
odoms.push(unique_cards(this_decklist))  # Returns [L, B]
card = odoms[-1].shift  # Only explores L first

# Should be:
# Generate all distinct orderings and explore each branch
# Use hash_to_list() to get [L, B, B] then call unique_permutation
```

### Unique Permutation Background
Repository already has [unique_permutation.rb](ruby_v1/unique_permutation.rb) implementing Knuth's Algorithm L for efficient deduplication. This can be:
1. Ported to ruby_v2
2. Used to initialize odom with actual card orderings instead of just types

### Test Validation  
Run all tests with:
```bash
cd ruby_v2
bundle exec rspec
```

*Last updated: March 10, 2026*

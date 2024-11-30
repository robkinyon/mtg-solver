# Add the unique_permutation method to the Array class.
# This is incredibly more efficient that the built in permutation method as duplicate elements will yield
# identical permutations.

# This is taken from the unique_permutation gem, but modified to skip
# invoking blocks if the first N cards (which won) haven't changed.
class Array
	def unique_permutation(&block)
    return enum_for(:unique_permutation) unless block_given?

    calls, total = 0, 0
    saved = {}
    array_copy = self.sort
    rv = yield array_copy.dup
    calls += 1
    total += 1
    saved[rv] = 1
    return saved, calls if size < 2

    anchor = false
    while true
      # Based off of Algorithm L (Donald Knuth)
      j = size - 2;
      j -= 1 while j > 0 && array_copy[j] >= array_copy[j+1]

      if array_copy[j] >= array_copy[j+1]
        break
      end

      l = size - 1
      l -= 1 while array_copy[j] >= array_copy[l]

      array_copy[j], array_copy[l] = array_copy[l], array_copy[j]
      array_copy[j+1..-1] = array_copy[j+1..-1].reverse

      if anchor && anchor < j && anchor < l
        saved[anchor] = (saved[anchor] || 0) + 1
        total += 1
      else
        rv = yield array_copy.dup
        calls += 1
        total += 1
        saved[rv] = (saved[rv] || 0) + 1
        anchor = rv == 0 ? false : rv
      end
    end
    return saved, calls, total
	end
end

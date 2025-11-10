#!/usr/bin/env ruby

puts "Hello"

$:.unshift "lib"
require "unique_permutationx"

l = [1,2,3,4]

l.unique_permutation {|x|
  puts "'#{x}'"
  next 1
}

puts "Ok"

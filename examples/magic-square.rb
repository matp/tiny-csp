#!/usr/bin/env ruby

require 'tiny-csp'

problem = TinyCsp::Problem.new(4) do |size|
  # Set up variables.
  (0...size * size).each do |i|
    variable i, (1..size * size)
  end

  # Sum for rows, columns and diagonals.
  sum = size * (size * size + 1) / 2

  # Predicate for rows, columns and diagonals.
  predicate = proc {|*args| args.inject(:+) == sum }

  # Set up row and column constraints.
  (0...size).each do |i|
    constraint(*(0...size).map {|j| i * size + j }, &predicate)
    constraint(*(0...size).map {|j| i + size * j }, &predicate)
  end

  # Set up diagonal constraints.
  constraint(*(0...size).map {|i| (size + 1) * i }, &predicate)
  constraint(*(1 ..size).map {|i| (size - 1) * i }, &predicate)

  # Set up all different constraint.
  all_different *(0...size * size)
end

solver = TinyCsp::BacktrackingSolver.new(problem)

solution = solver.solve
(0...solution.size).each_slice(Math.sqrt(solution.size)).each do |row|
  puts solution.values_at(*row)
               .map {|v| '%*d' % [solution.size.to_s.length, v] }
               .join(' ')
end

#!/usr/bin/env ruby

require 'tiny-csp'

problem = TinyCsp::Problem.new(8) do |size|
  # Set up variables.
  (1..size).each {|i| variable i, (1..size) }

  # Set up column constraints.
  all_different *(1..size)

  # Set up diagonal constraints.
  (1..size).to_a.combination(2) do |variable_x, variable_y|
    constraint(variable_x, variable_y) do |x, y|
      y != x - (variable_y - variable_x) && y != x + (variable_y - variable_x)
    end
  end
end

solver = TinyCsp::MinConflictsSolver.new(problem)

solution = solver.solve
(1..solution.size).each do |n|
  puts (1..solution.size).map {|c| solution[n] == c ? 'Q' : '.' }.join(' ')
end

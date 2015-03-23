#!/usr/bin/env ruby

require 'tiny-csp'

problem = TinyCsp::Problem.new(%w[
4 . . . . . 8 . 5 
. 3 . . . . . . . 
. . . 7 . . . . . 
. 2 . . . . . 6 . 
. . . . 8 . 4 . . 
. . . . 1 . . . . 
. . . 6 . 3 . 7 . 
5 . . 2 . . . . . 
1 . 4 . . . . . .]) do |grid|
  # Set up variables.
  (1..9).each do |row|
    (1..9).each do |col|
      if grid[(row - 1) * 9 + (col - 1)] =~ /\A(\d)\Z/
        variable "r#{row}c#{col}", $1.to_i
      else
        variable "r#{row}c#{col}", (1..9).to_a
      end
    end
  end

  # Set up row and column constraints.
  (1..9).each do |i|
    all_different *(1..9).map {|j| "r#{i}c#{j}" }
    all_different *(1..9).map {|j| "r#{j}c#{i}" }
  end

  # Set up region constraints.
  (1..9).each_slice(3) do |rows|
    (1..9).each_slice(3) do |cols|
      rows.product(cols).combination(2).each do |(row1, col1), (row2, col2)|
        next if row1 == row2 || col1 == col2
        constraint "r#{row1}c#{col1}", "r#{row2}c#{col2}" do |x, y|
          x != y
        end
      end
    end
  end
end

solver = TinyCsp::BacktrackingSolver.new(problem)
solution = solver.solve

solver.each_solution do |solution|
  print "+-------+-------+-------+\n"
  (1..9).each do |row|
    print '|'
    (1..9).each do |col|
      print " #{solution["r#{row}c#{col}"]}"
      print ' |' if col % 3 == 0
    end
    print "\n"
    print "+-------+-------+-------+\n" if row % 3 == 0
  end
end

class Solver
  attr_reader :problem

  def initialize(problem)
    @problem = problem
  end
end

require 'tiny-csp/solver/backtracking'
require 'tiny-csp/solver/minconflicts'

module TinyCsp
  class MinConflictsSolver < Solver
    def initialize(problem)
      super

      @constraints = Hash.new {|h, k| h[k] = Array.new }

      problem.constraints.each do |constraint|
        @constraints[constraint.variable_x] << constraint
        @constraints[constraint.variable_y] << constraint
      end
    end

    def solve
      assignments = random_initial_assignments
      unsatisfied = unsatisfied_constraints(problem.constraints, assignments)

      while !unsatisfied.empty?
        # Pick an unsatisfied contraint.
        constraint = unsatisfied.sample

        # Pick the next variable to assign a value to.
        variable = rand < 0.5 ? constraint.variable_x : constraint.variable_y
        next if variable.domain.values.size == 1

        # Try each other value in turn.
        current_value, candidates = assignments[variable.name], []

        variable.domain.values.each do |value|
          if value != current_value
            assignments[variable.name] = value
            candidates << [value,
              unsatisfied_constraints(@constraints[variable], assignments)]
          end
        end

        # Pick a candidate assignment.
        candidate = candidates.shuffle.min_by {|c| c[1].size }

        # Update assignments and unsatisfied constraints.
        assignments[variable.name] = candidate[0]
        unsatisfied -= @constraints[variable]
        unsatisfied += candidate[1]
      end

      assignments.reject {|n, _| n =~ /\A__auxilary_\d+\Z/ }
    end

    private

      def random_initial_assignments
        problem.variables.inject({}) do |assignments, (name, variable)|
          assignments[name] = variable.domain.values.sample
          assignments
        end
      end

      def unsatisfied_constraints(constraints, assignments)
        constraints.reject do |constraint|
          constraint.satisfied?(assignments[constraint.variable_x.name],
            assignments[constraint.variable_y.name])
        end
      end
  end
end

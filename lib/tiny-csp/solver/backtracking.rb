module TinyCsp
  class BacktrackingSolver < Solver
    def initialize(problem)
      super

      @arcs = Hash.new {|h, k| h[k] = Array.new }

      problem.constraints.each do |constraint|
        @arcs[constraint.variable_x] << ReverseArc.new(constraint)
        @arcs[constraint.variable_y] << ForwardArc.new(constraint)
      end
    end

    def solve
      each_solution {|s| return s }
    end

    def each_solution(&block)
      search(@arcs.values.inject(:+), &block)
    end

    private

      class Arc
        def initialize(constraint)
          @constraint = constraint
        end
      end

      class ForwardArc < Arc
        def tail ; @constraint.variable_x end
        def head ; @constraint.variable_y end

        def consistent?(x, y)
          @constraint.satisfied?(x, y)
        end
      end

      class ReverseArc < Arc
        def tail ; @constraint.variable_y end
        def head ; @constraint.variable_x end

        def consistent?(x, y)
          @constraint.satisfied?(y, x)
        end
      end

      def search(inconsistent_arcs, &block)
        problem.variables.each_value {|v| v.domain.push_state }

        if enforce_arc_consistency(inconsistent_arcs)
          if solved?
            yield solution
          else
            # Pick the next variable to assign a value to.
            variable = most_restricted_variable

            # Try each remaining value in turn.
            variable.domain.values.each do |value|
              variable.domain.push_state([value])
              search(@arcs[variable].dup, &block)
              variable.domain.pop_state
            end
          end
        end

        problem.variables.each_value {|v| v.domain.pop_state }
        nil
      end

      def enforce_arc_consistency(inconsistent_arcs)
        while arc = inconsistent_arcs.shift
          if reduce_arc(arc)
            return false if arc.tail.domain.values.empty?
            inconsistent_arcs += @arcs[arc.tail]
          end
        end
        true
      end

      def reduce_arc(arc)
        length = arc.tail.domain.values.size
        arc.tail.domain.values.reject! do |x|
          arc.head.domain.values.none? {|y| arc.consistent?(x, y) }
        end
        length != arc.tail.domain.values.size
      end

      def most_restricted_variable
        problem.variables.values.reject {|v| v.domain.values.size == 1 }
                                .min_by {|v| v.domain.values.size }
      end

      def solved?
        problem.variables.all? {|_, v| v.domain.values.size == 1 }
      end

      def solution
        problem.variables.inject({}) do |solution, (name, variable)|
          solution[name] = variable.domain.values.first if
            name !~ /\A__auxilary_\d+\Z/
          solution
        end
      end
  end
end

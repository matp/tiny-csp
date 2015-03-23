module TinyCsp
  class Constraint
    attr_reader :variable_x, :variable_y

    def initialize(variable_x, variable_y, &predicate)
      @variable_x, @variable_y, @predicate = variable_x, variable_y, predicate
    end

    def satisfied?(x, y)
      @predicate.call(x, y)
    end
  end
end

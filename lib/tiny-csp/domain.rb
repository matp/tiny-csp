module TinyCsp
  class Domain
    attr_reader :values

    def initialize(values)
      @states, @values = [], values.respond_to?(:to_a) ? values.to_a : [values]
    end

    def push_state(values = self.values.dup)
      @states << @values
      @values = values
    end

    def pop_state
      @values = @states.pop
    end
  end
end

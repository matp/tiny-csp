module TinyCsp
  class Problem
    attr_reader :variables, :constraints

    def initialize(*args, &block)
      @auxilary, @variables, @constraints = 0, {}, []
      instance_exec(*args, &block) if block_given?
    end

    def variable(name, domain)
      raise ArgumentError, "variable #{name} already exists" if
        @variables.has_key?(name)
      @variables[name] = Variable.new(name, domain)
    end

    def constraint(*variables, &predicate)
      raise ArgumentError, 'constraint requires a predicate' if
        !block_given?
      raise ArgumentError, 'constraint requires at least one variable' if
        variables.empty? && predicate.parameters.empty?

      # Extract variables from predicate if not specified.
      variables = predicate.parameters.map {|p| p[1] } if variables.empty?

      # Look up variables specified by name.
      variables = variables.map {|v| Variable === v ? v : @variables.fetch(v) }

      # Handle unary/binary/n-ary constraints.
      case variables.size
      when 1
        variables.first.domain.select!(&predicate)
      when 2
        @constraints << Constraint.new(*variables, &predicate)
      else
        auxilary = auxilary_variable_for(*variables, &predicate)
        variables.each_with_index do |variable, index|
          @constraints << Constraint.new(variable, auxilary) do |x, y|
            x == y[index]
          end
        end
      end
    end

    def all_different(*variables)
      variables.combination(2) do |variable_x, variable_y|
        constraint(variable_x, variable_y) do |x, y|
          x != y
        end
      end
    end

    private

      def auxilary_variable_for(*variables, &predicate)
        head, *tail = variables.map {|v| v.domain.values }
        variable = Variable.new("__auxilary_#{@auxilary += 1}",
          head.product(*tail).select {|v| predicate.call(*v) })
        @variables[variable.name] = variable
      end
  end
end

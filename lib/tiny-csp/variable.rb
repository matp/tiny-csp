module TinyCsp
  class Variable
    attr_reader :name, :domain

    def initialize(name, domain)
      @name, @domain = name, Domain === domain ? domain : Domain.new(domain)
    end
  end
end

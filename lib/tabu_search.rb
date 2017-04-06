module Scheduling
  class TabuSearch
    attr_accessor :steps, :max_tabu_size, :neighbours, :fitness

    def initialize(first_permutation, steps, fitness, max_tabu_size, neighbours)
      @current = first_permutation
      @steps = steps
      @fitness = fitness
      @max_tabu_size = max_tabu_size
      @neighbours = neighbours
    end

    def call
      @tabu = []
      @best = @current
      @best_fitness = fitness.call(@current)
      @steps.times do
        best_candidate = nil
        bf = -1.0 / 0
        neighbours.call(@current).each do |ne|
          if !@tabu.include?(ne) && (nef = fitness.call(ne)) > bf
            best_candidate = ne
            bf = nef
          end
        end
        break if best_candidate.nil?
        @current = best_candidate
        if bf > @best_fitness
          @best = @current
          @best_fitness = bf
        end
        add_to_tabu(@current)
      end
      @best
    end

    private

    def add_to_tabu(n)
      @tabu.unshift(n)
      @tabu.pop if @tabu.size > @max_tabu_size
    end
  end
end

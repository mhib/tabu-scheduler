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
        best_candidate, best_fitness = choose_best_neighbour
        break if best_candidate.nil?
        @current = best_candidate
        if best_fitness < @best_fitness
          @best = @current
          @best_fitness = best_fitness
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

    def choose_best_neighbour
      best_candidate = nil
      best_fitness = 1.0 / 0
      neighbours.call(@current).each do |ne|
        if !@tabu.include?(ne) && (nef = fitness.call(ne)) < best_fitness
          best_candidate = ne
          best_fitness = nef
        end
      end
      [best_candidate, best_fitness]
    end
  end
end

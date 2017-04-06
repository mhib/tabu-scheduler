module Scheduling
  class TabuRouletteSearch
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
        best_candidate, bf = roulette_choose(neighbours.call(@current).select { |ne| !@tabu.include? ne })
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

    def roulette_choose(perms)
      return [nil, -1.0 / 0] if perms.empty?
      sum = 0
      cache = {}
      perms.each do |n|
        cache[n] = fit = @fitness.call(n).to_r
        return [n, fit] if fit > @best_fitness
        sum += 1 / fit
      end
      sel = rand(sum..0)
      perms.each do |n|
        sel -= 1 / cache[n]
        return [n, cache[n]] if sel >= 0
      end
      [perms.last, cache[perms.last]]
    end
  end
end

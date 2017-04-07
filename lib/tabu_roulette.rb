module Scheduling
  class TabuRouletteSearch
    ROULETTE_STRING_ID = 'roulette'.freeze

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
      best = [nil, -1.0 / 0]
      cache = perms.map do |n|
        fit = @fitness.call(n).to_f
        sum += 1 / fit
        best = [n, fit] if fit > best[1]
        [n, fit]
      end
      return best if best[1] > @best_fitness
      sel = rand(sum..0)
      cache.shuffle.each do |perm, fit|
        sel -= 1 / fit
        return [perm, fit] if sel >= 0
      end
      cache.last
    end
  end
end

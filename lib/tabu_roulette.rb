module Scheduling
  class TabuRouletteSearch < TabuSearch
    ROULETTE_STRING_ID = 'roulette'.freeze

    private

    def choose_best_neighbour
      roulette_choose(neighbours.call(@current).reject { |ne| @tabu.include? ne })
    end

    def roulette_choose(perms)
      return [nil, 1.0 / 0] if perms.empty?
      sum = 0
      best = [nil, 1.0 / 0]
      cache = perms.map do |n|
        fit = @fitness.call(n).to_f
        sum += 1 / fit
        best = [n, fit] if fit < best[1]
        [n, fit]
      end.shuffle!
      return best if best[1] < @best_fitness
      sel = rand(0..sum)
      cache.each do |perm, fit|
        sel -= 1 / fit
        return [perm, fit] if sel <= 0
      end
      cache.last
    end
  end
end

require_relative 'fuzzy_number'
require_relative 'tabu_search'
require_relative 'time_prediction'

module Scheduling
  class ProblemAllPermutations
    attr_reader :input, :building_count, :machine_count
    def initialize(input, building_count, machine_count, *_args)
      @input = input.group_by(&:machine)
      @starting = (1..building_count).to_a
      @building_count = building_count
      @machine_count = machine_count
    end

    def call
      res = @starting.permutation.min_by(&method(:fitness))
      [[res], cost(res)]
    end

    def fitness(x)
      cost(x).defuzzyficate
    end

    def cost(x)
      return 1.0 / 0 if x.nil?
      c = Array.new(machine_count + 1) { [] }
      (1..machine_count).each do |i|
        (1..building_count).each do |j|
          el = input[i][x[j - 1] - 1].number
          ci = c[i - 1].fetch(j) { FuzzyNumber.zero }
          cj = c[i].fetch(j - 1) { FuzzyNumber.zero }
          c[i][j] = FuzzyNumber.new(
            [ci.min, cj.min].max,
            [ci.mid, cj.mid].max,
            [ci.max, cj.max].max
          ).add(el)
        end
      end
      c[machine_count][building_count]
    end
  end
end

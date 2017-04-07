require_relative 'fuzzy_number'
require_relative 'tabu_search'
require_relative 'time_prediction'

module Scheduling
  class ProblemEasier
    attr_reader :input, :building_count, :machine_count, :iterations, :tabu_size
    attr_accessor :tabu_type
    def initialize(input, building_count, machine_count, iterations, tabu_size, taby_type)
      @input = input.group_by(&:machine)
      @starting = (1..building_count).to_a
      @building_count = building_count
      @machine_count = machine_count
      @iterations = iterations
      @combinations = (0...building_count).to_a.combination(2).to_a
      @tabu_size = tabu_size
      @tabu_type = tabu_type
    end

    def call
      klass = tabu_type == TabuRouletteSearch::ROULETTE_STRING_ID ? TabuRouletteSearch : TabuSearch
      res = klass.new(@starting.dup, iterations, method(:fitness).to_proc, tabu_size, method(:neighbours).to_proc).call
      [[res], cost(res)]
    end

    def fitness(x)
      fuzzed = cost(x)
      -0.25 * (fuzzed.min + fuzzed.mid + fuzzed.mid + fuzzed.max)
    end

    def cost(x)
      return -1.0 / 0 if x.nil?
      c = Array.new(@machine_count + 1) { [] }
      (1..@machine_count).each do |i|
        (1..@building_count).each do |j|
          el = @input[i][x[j - 1] - 1].number
          ci = c[i - 1].fetch(j) { FuzzyNumber.new(0.0, 0.0, 0.0) }
          cj = c[i].fetch(j - 1) { FuzzyNumber.new(0.0, 0.0, 0.0) }
          c[i][j] = FuzzyNumber.new(
            [ci.min, cj.min].max + el.min,
            [ci.mid, cj.mid].max + el.mid,
            [ci.max, cj.max].max + el.max
          )
        end
      end
      c[@machine_count][@building_count]
    end

    def neighbours(perm)
      Enumerator.new do |yielder|
        @combinations.shuffle.each do |l, k|
          yielder << permute(perm.dup, l, k)
        end
      end
    end

    private

    def permute(a, l, k)
      a[l], a[k] = a[k], a[l]
      a
    end
  end
end

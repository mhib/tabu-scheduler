require_relative 'fuzzy_number'
require_relative 'tabu_search'
require_relative 'time_prediction'

module Scheduling
  class ProblemEasier
    attr_reader :input, :building_count, :machine_count, :iterations, :tabu_size
    attr_accessor :tabu_type
    def initialize(input, building_count, machine_count, iterations, tabu_size, tabu_type)
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
      cost(x).defuzzyficate
    end

    def cost(x)
      return 1.0 / 0 if x.nil?
      c = Array.new(@machine_count + 1) { [] }
      (1..@machine_count).each do |i|
        (1..@building_count).each do |j|
          el = @input[i][x[j - 1] - 1].number
          ci = c[i - 1].fetch(j) { FuzzyNumber.zero }
          cj = c[i].fetch(j - 1) { FuzzyNumber.zero }
          c[i][j] = FuzzyNumber.new(
            [ci.min, cj.min].max,
            [ci.mid, cj.mid].max,
            [ci.max, cj.max].max
          ).add(el)
        end
      end
      c[@machine_count][@building_count]
    end

    def neighbours(perm)
      Enumerator.new do |yielder|
        @combinations.shuffle.each do |l, k|
          yielder << perm.dup.tap { |p| p[l], p[k] = p[k], p[l] }
        end
      end
    end
  end
end

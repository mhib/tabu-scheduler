require_relative 'fuzzy_number'
require_relative 'tabu_search'
require_relative 'time_prediction'
require_relative 'costable'

module Scheduling
  class ProblemEasier
    include Costable

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

    def neighbours(perm)
      Enumerator.new do |yielder|
        @combinations.shuffle.each do |l, k|
          yielder << perm.dup.tap { |p| p[l], p[k] = p[k], p[l] }
        end
      end
    end

    private

    def get_element(x, i, j)
      @input[i][x[j - 1] - 1].number
    end
  end
end

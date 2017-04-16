require_relative 'fuzzy_number'
require_relative 'tabu_search'
require_relative 'time_prediction'
require_relative 'costable'

module Scheduling
  class ProblemAllPermutations
    include Costable

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

    private

    def get_element(x, i, j)
      input[i][x[j - 1] - 1].number
    end
  end
end

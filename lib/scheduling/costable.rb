require 'scheduling/fuzzy_number'

module Scheduling
  module Costable
    NotImplementedError = Class.new(StandardError)

    def fitness(x)
      cost(x).defuzzyficate
    end

    def cost(x)
      return 1.0 / 0 if x.nil?
      c = Array.new(machine_count + 1) { [] }
      (1..machine_count).each do |i|
        (1..building_count).each do |j|
          el = get_element(x, i, j)
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

    private

    [:machine_count, :building_count, :get_element].each do |sym|
      define_method sym do |*_args|
        raise NotImplementedError, "#{sym} method is not implemented!"
      end
    end
  end
end

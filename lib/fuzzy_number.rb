require 'equalizer'

module Scheduling
  class FuzzyNumber
    # Not really needed in this project
    include Equalizer.new(:min, :mid, :max)

    attr_accessor :min, :mid, :max
    def initialize(min, mid, max)
      @min = min.to_f
      @mid = mid.to_f
      @max = max.to_f
    end

    def call(x)
      return 0.0 if x < min || x > max
      return 1.0 if x == @mid
      return -1.0 / (@min - @mid) * x + (1.0 / (@min - @mid) * @min) if x < @mid
      -1.0 / (@max - @mid) * x + (1.0 / (@max - @mid) * @max)
    end

    def include?(x)
      x >= min && x <= max
    end
  end
end

require 'equalizer'

module Scheduling
  class FuzzyNumber
    # Not really needed in this project
    include Equalizer.new(:min, :mid, :max)

    attr_accessor :min, :mid, :max
    def initialize(min, mid, max)
      @min = min
      @mid = mid
      @max = max
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

    def defuzzyficate
      (min + mid + mid + max) / 4.0
    end

    def add(other)
      @min += other.min
      @mid += other.mid
      @max += other.max
      self
    end

    def +(other)
      dup.add(other)
    end

    def self.zero
      new(0.0, 0.0, 0.0)
    end
  end
end

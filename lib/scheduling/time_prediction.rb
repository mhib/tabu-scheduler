require 'scheduling/fuzzy_number'

module Scheduling
  class TimePrediction
    attr_reader :building, :machine, :number
    def initialize(building, machine, min, mid, max)
      @machine = machine.to_i
      @building = building.to_i
      @number = FuzzyNumber.new(min, mid, max).freeze
    end
  end
end

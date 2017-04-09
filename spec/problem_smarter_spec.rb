require 'problem_smarter'

RSpec.describe Scheduling::ProblemSmarter do
  describe '#neighbours' do
    let(:machine_count) { 2 }
    let(:building_count) { 3 }
    let(:start) do
      [
        Scheduling::TimePrediction.new(1, 1, 1, 3, 5),
        Scheduling::TimePrediction.new(2, 1, 2, 4, 5),
        Scheduling::TimePrediction.new(1, 2, 1, 3, 4),
        Scheduling::TimePrediction.new(2, 2, 1, 1.5, 2),
        Scheduling::TimePrediction.new(1, 3, 2, 3, 4),
        Scheduling::TimePrediction.new(2, 3, 1.5, 1.74, 2),
      ]
    end
    let(:problem) do
      Scheduling::ProblemSmarter.new(start, building_count, machine_count, 20, 5, 'random'.freeze)
    end

    it 'returns all valid neighbours' do
      expect(problem.neighbours((1..machine_count).map { (1..building_count).to_a })).to match_array([
        [[1, 2, 3], [1, 3, 2]],
        [[1, 2, 3], [2, 1, 3]],
        [[1, 2, 3], [3, 2, 1]],
        [[1, 3, 2], [1, 2, 3]],
        [[2, 1, 3], [1, 2, 3]],
        [[3, 2, 1], [1, 2, 3]]
      ])
    end
  end
end

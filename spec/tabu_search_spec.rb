require 'tabu_search'
require 'prime'

RSpec.describe Scheduling::TabuSearch do
  describe "Primes at beginning of array" do
    let(:array) { (1..100).to_a }
    let(:array_size) { 100 }
    let(:fitness) { lambda { |x| -x[0..25].count(&:prime?) } }
    let(:starting_fitness) { fitness.call(array) }
    let(:neighbours) do
      lambda do |x|
        (0...array_size).to_a.combination(2).to_a.sample(26).map do |l, r|
          e = x.dup
          e[l], e[r] = e[r], e[l]
          e
        end
      end
    end

    it 'generates better result than input' do
      search = Scheduling::TabuSearch.new(array, 10, fitness, 5, neighbours)
      expect(fitness.call search.call).to be < starting_fitness
    end
  end
end

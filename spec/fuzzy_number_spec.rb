require 'scheduling/fuzzy_number'
RSpec.describe Scheduling::FuzzyNumber do
  describe '#==' do
    context 'same values' do
      let(:fuzzy1) { Scheduling::FuzzyNumber.new(1, 2, 3) }
      let(:fuzzy2) { Scheduling::FuzzyNumber.new(1, 2, 3) }
      it 'is true' do
        expect(fuzzy1 == fuzzy2).to eq true
      end
    end

    context 'other values' do
      let(:fuzzy1) { Scheduling::FuzzyNumber.new(1, 2, 3) }
      let(:fuzzy2) { Scheduling::FuzzyNumber.new(2, 2, 3) }
      let(:fuzzy3) { Scheduling::FuzzyNumber.new(1, 3, 3) }
      let(:fuzzy4) { Scheduling::FuzzyNumber.new(1, 2, 4) }
      let(:fuzzy5) { Scheduling::FuzzyNumber.new(2, 3, 4) }
      it 'is false' do
        expect(fuzzy1 == fuzzy2).to eq false
        expect(fuzzy1 == fuzzy3).to eq false
        expect(fuzzy1 == fuzzy4).to eq false
        expect(fuzzy1 == fuzzy5).to eq false
      end
    end
  end

  describe '#include?' do
    context 'value in range' do
      let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }

      it 'is true' do
        expect(fuzzy.include?(1.5)).to eq true
      end
    end

    context 'value not in range' do
      let(:fuzzy) { Scheduling::FuzzyNumber.new(2, 3, 4) }

      it 'is false' do
        expect(fuzzy.include?(1.5)).to eq false
      end
    end
  end

  describe '#call' do
    context 'left side' do
      let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }

      it 'has correct value' do
        expect(fuzzy.call(1.5)).to eq 0.5
      end
    end

    context 'right side' do
      let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }

      it 'has correct value' do
        expect(fuzzy.call(2.5)).to eq 0.5
      end
    end

    context 'mid' do
      let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }

      it 'has correct value' do
        expect(fuzzy.call(2)).to eq 1
      end
    end

    context 'min' do
      let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }

      it 'has correct value' do
        expect(fuzzy.call(1)).to eq 0
      end
    end

    context 'max' do
      let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }

      it 'has correct value' do
        expect(fuzzy.call(3)).to eq 0
      end
    end

    context 'out of range' do
      let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }

      it 'has correct value' do
        expect(fuzzy.call(3.5)).to eq (0)
      end
    end
  end

  describe '#defuzzyficate' do
    let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }

    it 'has correct value' do
      expect(fuzzy.defuzzyficate).to eq (1 + 2 + 2 + 3) / 4.0
    end
  end

  describe '#add' do
    let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }
    let(:fuzzy2) { Scheduling::FuzzyNumber.new(4, 5, 6) }

    it 'it adds fuzzy numbers' do
      num = fuzzy.add(fuzzy2)
      expect(num.min).to eq 5
      expect(num.mid).to eq 7
      expect(num.max).to eq 9
    end

    it 'mutates object' do
      fuzzy.add(fuzzy2)
      expect(fuzzy.min).to eq 5
      expect(fuzzy.mid).to eq 7
      expect(fuzzy.max).to eq 9
    end
  end

  describe '#+' do
    let(:fuzzy) { Scheduling::FuzzyNumber.new(1, 2, 3) }
    let(:fuzzy2) { Scheduling::FuzzyNumber.new(4, 5, 6) }

    it 'it adds fuzzy numbers' do
      num = fuzzy + fuzzy2
      expect(num.min).to eq 5
      expect(num.mid).to eq 7
      expect(num.max).to eq 9
    end

    it 'does not mutate object' do
      _res = fuzzy + fuzzy2
      expect(fuzzy.min).to eq 1
      expect(fuzzy.mid).to eq 2
      expect(fuzzy.max).to eq 3
    end
  end
end

require_relative '../../../lib/quoridor/game'

RSpec.describe(Quoridor::Game) do
  describe '.new' do
    it 'allows 2 players' do
      expect(described_class.new([nil, nil])).not_to be_nil
    end

    it 'allows 4 players' do
      expect(described_class.new([nil, nil, nil, nil])).not_to be_nil
    end

    it 'does not allow any other number of players' do
      error_message = 'Only 2 or 4 players per game allowed'

      expect { described_class.new([]) }.to raise_error(ArgumentError, error_message)
      expect { described_class.new([nil,]) }.to raise_error(ArgumentError, error_message)
      expect { described_class.new([nil, nil, nil]) }.to raise_error(ArgumentError, error_message)
      expect { described_class.new([nil, nil, nil, nil, nil, nil]) }.to raise_error(ArgumentError, error_message)
    end
  end

  describe '#turn' do
    let(:game) { described_class.new(['James', 'Jean-Luc', 'Benjamin', 'Kathryn'])}

    it 'starts with the first player' do
      expect(game.turn).to eq(0)
    end

    it 'iterates with each move' do
      game.move(0, 'e8')
      expect(game.turn).to eq(1)

      game.move(1, 'e2')
      expect(game.turn).to eq(2)

      game.move(2, 'h5')
      expect(game.turn).to eq(3)

      game.move(3, 'b5')
      expect(game.turn).to eq(0)
    end
  end
end
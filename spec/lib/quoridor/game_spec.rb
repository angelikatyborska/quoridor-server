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

    it 'increments with each valid move' do
      game.move(0, 'e8')
      expect(game.turn).to eq(1)

      game.move(1, 'e2')
      expect(game.turn).to eq(2)

      game.move(2, 'b5')
      expect(game.turn).to eq(3)

      game.move(3, 'h5')
      expect(game.turn).to eq(0)
    end
  end

  describe '#move' do
    let(:game) { described_class.new(['Quark', 'Rom'])}

    it 'checks whose turn it is' do
      expect { game.move(1, 'e2') }.to raise_error(ArgumentError, 'It is not player 1\'s turn')
    end

    it 'detect invalid move' do
      expect { game.move(0, 'asdfasdf') }.to raise_error(ArgumentError, 'Invalid move asdfasdf')
    end

    it 'detect invalid movement' do
      expect { game.move(0, 'e5') }.to raise_error(ArgumentError, 'Invalid movement e5 for player 0')
    end

    it 'detect invalid fence placement' do
      game.move(0, 'd2v')
      game.move(1, 'e2v')
      expect { game.move(0, 'd3h') }.to raise_error(ArgumentError, 'Invalid fence placement d3h')
    end

    it 'returns a winner' do
      %w(e8 e2 e7 e3 e6 e4 e5 e6 e4 e7 e3 e8 e2).each_with_index do |move, index|
        result = game.move(index % 2, move)
        expect(result[:winner]).to be nil
      end

      result = game.move(1, 'e9')
      expect(result[:winner]).to be 1
    end
  end
end
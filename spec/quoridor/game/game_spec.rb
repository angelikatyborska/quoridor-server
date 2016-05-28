require_relative '../../../lib/quoridor/game/game'
require_relative '../../../lib/quoridor/errors'

RSpec.describe(Quoridor::Game::Game) do
  describe '.new' do
    it 'allows 2 players' do
      expect(described_class.new([nil, nil])).not_to be_nil
    end

    it 'allows 4 players' do
      expect(described_class.new([nil, nil, nil, nil])).not_to be_nil
    end

    it 'does not allow any other number of players' do
      error_message = ->(n) { "Invalid number of players #{n}, allowed: 2, 4" }

      expect { described_class.new([]) }
        .to raise_error(Quoridor::InvalidNumberOfPlayers, error_message.(0))
      expect { described_class.new([nil,]) }
        .to raise_error(Quoridor::InvalidNumberOfPlayers, error_message.(1))
      expect { described_class.new([nil, nil, nil]) }
        .to raise_error(Quoridor::InvalidNumberOfPlayers, error_message.(3))
      expect { described_class.new([nil, nil, nil, nil, nil, nil]) }
        .to raise_error(Quoridor::InvalidNumberOfPlayers, error_message.(6))
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
      expect { game.move(1, 'e2') }.to raise_error(Quoridor::OutOfTurn, 'It is not player 1\'s turn')
    end

    it 'detect invalid move' do
      expect { game.move(0, 'asdfasdf') }.to raise_error(Quoridor::InvalidMove, 'Invalid move asdfasdf')
    end

    it 'detect invalid movement' do
      expect { game.move(0, 'e5') }.to raise_error(Quoridor::InvalidMovement, 'Invalid movement e5 for player 0')
    end

    it 'detects invalid fence placement' do
      game.move(0, 'd2v')
      game.move(1, 'e2v')
      expect { game.move(0, 'd3h') }.to raise_error(Quoridor::InvalidFencePlacement, 'Invalid fence placement d3h')
    end

    it 'detects player has no fences left' do
      10.times do |n|
        game.move(0, "#{n % 2 == 1 ? 'a' : 'c'}#{n % 7 + 2}h")
        game.move(1, "e#{n % 2 + 2}")
      end

      expect { game.move(0, 'f3h') }.to raise_error(Quoridor::InvalidFencePlacement, 'Invalid fence placement f3h')
    end

    it 'sets the winner' do
      %w(e8 e2 e7 e3 e6 e4 e5 e6 e4 e7 e3 e8 e2).each_with_index do |move, index|
        game.move(index % 2, move)
        expect(game.winner).to be nil
      end

      game.move(1, 'e9')
      expect(game.winner).to eq(1)
    end

    it 'detects there already is a winner' do
      %w(e8 e2 e7 e3 e6 e4 e5 e6 e4 e7 e3 e8 e2 e9).each_with_index do |move, index|
        game.move(index % 2, move)
      end

      expect { game.move(0, 'e1') }.to raise_error(Quoridor::Error, 'Game has already ended')
    end
  end

  describe '#state' do
    let(:game) { described_class.new(['Jake', 'Nog'])}

    before(:each) do
      game.move(0, 'e8')
      game.move(1, 'e2')
      game.move(0, 'h3h')
    end

    it 'returns info about game state' do
      expect(game.state[:pawns]).to match_array(%w(e8 e2))
      expect(game.state[:fences]).to match_array(%w(h3h))
      expect(game.state[:possible_moves]).to include(:fences, :movements)
      expect(game.state[:turn]).to eq(1)
      expect(game.state[:winner]).to eq(nil)
      expect(game.state[:fences_left]).to eq([9, 10])
    end
  end
end
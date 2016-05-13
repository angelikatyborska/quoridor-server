require_relative '../../../lib/quoridor/game'

RSpec.describe(Game) do
  describe '#new' do
    it 'allows 2 players' do
      expect(Game.new([nil, nil])).not_to be_nil
    end

    it 'allows 4 players' do
      expect(Game.new([nil, nil, nil, nil])).not_to be_nil
    end

    it 'does not allow any other number of players' do
      error_message = 'Only 2 or 4 players per game allowed'

      expect { Game.new([]) }.to raise_error(ArgumentError, error_message)
      expect { Game.new([nil,]) }.to raise_error(ArgumentError, error_message)
      expect { Game.new([nil, nil, nil]) }.to raise_error(ArgumentError, error_message)
      expect { Game.new([nil, nil, nil, nil, nil, nil]) }.to raise_error(ArgumentError, error_message)
    end
  end
end
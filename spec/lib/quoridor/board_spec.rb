require_relative '../../../lib/quoridor/board'

RSpec.describe(Board) do
  let(:board) { Board.new }

  describe '#add_player' do
    it 'validates square' do
      error_message =  ->(square) { "Invalid square #{square}, must be between a1 and i9" }

      expect { board.add_player('a1') }.not_to raise_error
      expect { board.add_player('i9') }.not_to raise_error

      expect { board.add_player('a0') }.to raise_error(ArgumentError, error_message.('a0'))
      expect { board.add_player('i20') }.to raise_error(ArgumentError, error_message.('i20'))
      expect { board.add_player('j10') }.to raise_error(ArgumentError, error_message.('j10'))
      expect { board.add_player('abc') }.to raise_error(ArgumentError, error_message.('abc'))
    end

    it 'adds a player' do
      expect { board.add_player('a1') }.to change(board.players, :count).by(1)
      expect(board.players[0]).to eq('a1')
    end
  end

  describe '#move_player' do
    before(:each) do
      board.add_player('a1')
    end

    it 'validates square' do
      error_message =  ->(square) { "Invalid square #{square}, must be between a1 and i9" }

      expect { board.move_player(0, 'e3') }.not_to raise_error
      expect { board.move_player(0, 'g1') }.not_to raise_error

      expect { board.move_player(0, 'x1') }.to raise_error(ArgumentError, error_message.('x1'))
      expect { board.move_player(0, 'a10') }.to raise_error(ArgumentError, error_message.('a10'))
      expect { board.move_player(0, 't1') }.to raise_error(ArgumentError, error_message.('t1'))
      expect { board.move_player(0, '123') }.to raise_error(ArgumentError, error_message.('123'))
    end

    it 'moves the player' do
      expect { board.move_player(0, 'e3') }.to change {board.players[0]}.from('a1').to('e3')
    end
  end
end
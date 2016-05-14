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

  describe '#fence?' do
    error_message =  ->(square) { "Invalid square #{square}, must be between a1 and i9" }

    context 'without fences' do
      it 'returns false' do
        expect(board.fence?('a1', 'b1')).to be false
        expect(board.fence?('a1', 'f4')).to be false
      end

      it 'validates squares' do
        expect { board.fence?('x1', 'a1') }.to raise_error(ArgumentError, error_message.('x1'))
      end
    end

    context 'with fences' do
      before(:each) do
        board.add_fence('a2v')
      end

      it 'detects fences' do
        expect(board.fence?('a1', 'b1')).to be true
        expect(board.fence?('a2', 'b2')).to be true

        expect(board.fence?('a1', 'a2')).to be false
        expect(board.fence?('b1', 'b2')).to be false
        expect(board.fence?('a3', 'b3')).to be false
      end
    end
  end

  describe '#neighboring_squares' do
    context 'square in the middle' do
      subject(:neighboring) { board.neighboring_squares('e4') }

      it 'returns neighboring squares' do
        expect(neighboring).to contain_exactly('e5', 'd4', 'e3', 'f4')
      end
    end

    context 'square in the top row' do
      subject(:neighboring) { board.neighboring_squares('d9') }

      it 'returns neighboring squares' do
        expect(neighboring).to contain_exactly('c9', 'd8', 'e9')
      end
    end

    context 'square in the bottom left corner' do
      subject(:neighboring) { board.neighboring_squares('a1') }

      it 'returns neighboring squares' do
        expect(neighboring).to contain_exactly('b1', 'a2')
      end
    end
  end

  describe '#north #east #south #west' do
    error_message =  ->(square) { "Invalid square #{square}, must be between a1 and i9" }

    it 'validates squares' do
      expect { board.north('x1') }.to raise_error(ArgumentError, error_message.('x1'))
      expect { board.east('asdf') }.to raise_error(ArgumentError, error_message.('asdf'))
      expect { board.south('y4') }.to raise_error(ArgumentError, error_message.('y4'))
      expect { board.west('a888') }.to raise_error(ArgumentError, error_message.('a888'))
    end

    it 'handles a square in the middle' do
      expect(board.north('e3')).to eq('e4')
      expect(board.east('e3')).to eq('f3')
      expect(board.south('e3')).to eq('e2')
      expect(board.west('e3')).to eq('d3')
    end

    it 'handles a square in the top row' do
      expect(board.north('b9')).to be nil
      expect(board.east('b9')).to eq('c9')
      expect(board.south('b9')).to eq('b8')
      expect(board.west('b9')).to eq('a9')
    end

    it 'handles a square in the bottom left corner' do
      expect(board.north('a1')).to eq('a2')
      expect(board.east('a1')).to eq('b1')
      expect(board.south('a1')).to be nil
      expect(board.west('a1')).to be nil
    end
  end
end
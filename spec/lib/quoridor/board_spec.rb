require_relative '../../../lib/quoridor/board'

RSpec.describe(Quoridor::Board) do
  let(:board) { described_class.new }

  describe '#add_pawn' do
    it 'detects invalid squares' do
      expect { board.add_pawn('j10') }.to detect_invalid_square
      expect { board.add_pawn('abc') }.to detect_invalid_square
    end

    it 'adds a pawn' do
      expect { board.add_pawn('a1') }.to change(board.pawns, :count).by(1)
      expect(board.pawns[0]).to eq('a1')
    end

    it 'does not allow to put a pawn on a pawn' do
      board.add_pawn('a1')
      expect { board.add_pawn('a1') }.to raise_error(ArgumentError, 'Square a1 is already taken by pawn 0')
    end
  end

  describe '#move_pawn' do
    before(:each) do
      board.add_pawn('a1')
    end

    it 'detects invalid squares' do
      expect { board.move_pawn(0, 't1') }.to detect_invalid_square
      expect { board.move_pawn(0, '123') }.to detect_invalid_square
    end

    it 'detects invalid pawns' do
      expect { board.move_pawn(1, 'a1') }.to detect_invalid_pawn
      expect { board.move_pawn(42, 'a1') }.to detect_invalid_pawn
    end

    it 'moves the pawn' do
      expect { board.move_pawn(0, 'e3') }.to change {board.pawns[0]}.from('a1').to('e3')
    end

    it 'does not allow to put a pawn on a pawn' do
      board.add_pawn('e4')
      expect { board.move_pawn(0, 'e4') }.to raise_error(ArgumentError, 'Square e4 is already taken by pawn 1')
    end
  end

  describe '#add_fence' do
    it 'detects invalid squares' do
      expect { board.add_fence('j1v') }.to detect_invalid_square
    end

    it 'detects invalid fences' do
      expect { board.add_fence('a1z') }.to raise_error(ArgumentError, 'Invalid fence a1z')
    end

    context 'in the middle of an empty board' do
      it 'allows vertically' do
        expect { board.add_fence('e3v') }.not_to raise_error
      end

      it 'allows horizontally' do
        expect { board.add_fence('e3h') }.not_to raise_error
      end
    end

    context 'in the southernmost row' do
        it 'does not allow vertically' do
          expect { board.add_fence('a1v') }.to raise_error(ArgumentError, 'Cannot place a fence outside of the board')
        end

        it 'does not allow horizontally' do
          expect { board.add_fence('a1h') }.to raise_error(ArgumentError, 'Cannot place a fence outside of the board')
        end
    end

    context 'in the easternmost column' do
        it 'does not allow vertically' do
          expect { board.add_fence('i5v') }.to raise_error(ArgumentError, 'Cannot place a fence outside of the board')
        end

        it 'does not allow horizontally' do
          expect { board.add_fence('i5h') }.to raise_error(ArgumentError, 'Cannot place a fence outside of the board')
        end
    end

    context 'on an existing fence' do
      before(:each) do
        board.add_fence('c3h')
      end

      it 'does not allow overlapping' do
        expect { board.add_fence('b3h') }.to raise_error(ArgumentError, 'Cannot place a fence on another fence')
        expect { board.add_fence('c3h') }.to raise_error(ArgumentError, 'Cannot place a fence on another fence')
        expect { board.add_fence('d3h') }.to raise_error(ArgumentError, 'Cannot place a fence on another fence')
        expect { board.add_fence('c3v') }.to raise_error(ArgumentError, 'Cannot place a fence on another fence')
      end

      it 'allows a fence to the nort' do
        expect { board.add_fence('c2h') }.not_to raise_error
      end

      it 'allows a fence to the south' do
        expect { board.add_fence('c4h') }.not_to raise_error
      end

      it 'allows a fence to the west' do
        expect { board.add_fence('b3v') }.not_to raise_error
      end

      it 'allows a fence to the east' do
        expect { board.add_fence('d3v') }.not_to raise_error
      end
    end
  end

  describe '#fence?' do
    context 'without fences' do
      it 'returns false' do
        expect(board.fence?('a1', 'b1')).to be false
        expect(board.fence?('a1', 'f4')).to be false
      end

      it 'detects invalid squares' do
        expect { board.fence?('x1', 'a1') }.to detect_invalid_square
        expect { board.fence?('3e', 'a1') }.to detect_invalid_square
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
    it 'detects invalid squares' do
      expect { board.north('x1') }.to detect_invalid_square
      expect { board.east('asdf') }.to detect_invalid_square
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
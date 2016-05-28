require_relative '../../../lib/quoridor/game/board'
require_relative '../../../lib/quoridor/rules/movement'

RSpec.describe Quoridor::Rules::Movement do
  let(:board) { Quoridor::Game::Board.new }
  let(:rules) { described_class }

  describe '#possible_movements' do
    context 'no fences, one pawn' do
      context 'from the northmost row' do
        before(:each) do
          board.add_pawn('e9')
        end

        it 'allows movement: east, south, west' do
          expect(rules.possible_movements(board, 0)).to contain_exactly(*%w(f9 e8 d9))
        end
      end

      context 'from the eastmost row' do
        before(:each) do
          board.add_pawn('i5')
        end

        it 'allows movement: north, south, west' do
          expect(rules.possible_movements(board, 0)).to contain_exactly(*%w(i6 h5 i4))
        end
      end

      context 'from the middle' do
        before(:each) do
          board.add_pawn('e5')
        end

        it 'allows movement: north, east, south, west' do
          expect(rules.possible_movements(board, 0)).to contain_exactly(*%w(e6 f5 e4 d5))
        end
      end
    end

    context 'some fences, one pawn' do
      before(:each) do
        board.add_pawn('e5')
        board.add_fence('d5v')
        board.add_fence('e5h')
      end

      it 'allows movement: north, east' do
        expect(rules.possible_movements(board, 0)).to contain_exactly(*%w(e6 f5))
      end
    end

    context 'no fences, two pawns' do
      context 'two pawns facing each other' do
        before(:each) do
          board.add_pawn('e5')
          board.add_pawn('e6')
        end

        it 'allows to jump over the other pawn' do
          expect(rules.possible_movements(board, 0)).to contain_exactly(*%w(f5 e4 d5 e7))
          expect(rules.possible_movements(board, 1)).to contain_exactly(*%w(f6 e4 d6 e7))
        end
      end
    end

    context 'some fences, two pawns' do
      before(:each) do
        board.add_pawn('e5')
        board.add_pawn('e6')
        board.add_fence('d7v')
        board.add_fence('e7h')
        board.add_fence('e5h')
      end

      it 'allows movement to the sides if it is impossible to jump over the other pawn' do
        expect(rules.possible_movements(board, 0)).to contain_exactly(*%w(f5 d5 f6))
        expect(rules.possible_movements(board, 1)).to contain_exactly(*%w(f6 f5 d5))
      end
    end

    context 'some fences, four pawns' do
      before(:each) do
        board.add_pawn('e5')
        board.add_pawn('e6')
        board.add_pawn('e7')
        board.add_pawn('d6')
        board.add_fence('e7v')
      end

      it 'does not allow jumping over more than one pawn' do
        expect(rules.possible_movements(board, 0)).to contain_exactly(*%w(e4 f5 d5))
        expect(rules.possible_movements(board, 1)).to contain_exactly(*%w(e4 e8 c6))
        expect(rules.possible_movements(board, 2)).to contain_exactly(*%w(e8 d7))
        expect(rules.possible_movements(board, 3)).to contain_exactly(*%w(d7 d5 c6))
      end
    end
  end
end
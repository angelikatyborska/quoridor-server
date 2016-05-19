require_relative '../../../lib/quoridor/board'
require_relative '../../../lib/quoridor/rules'

RSpec.describe Quoridor::Rules do
  let(:board) { Quoridor::Board.new }
  let(:rules) { described_class.new }

  describe '#possible_moves' do
    context 'no fences, one pawn' do
      context 'from the northmost row' do
        before(:each) do
          board.add_pawn('e9')
        end

        it 'allows movement: east, south, west' do
          expect(rules.possible_moves(board, 0)).to contain_exactly('f9', 'e8', 'd9')
        end
      end

      context 'from the eastmost row' do
        before(:each) do
          board.add_pawn('i5')
        end

        it 'fallows movement: north, south, west' do
          expect(rules.possible_moves(board, 0)).to contain_exactly('i6', 'h5', 'i4')
        end
      end

      context 'from the middle' do
        before(:each) do
          board.add_pawn('e5')
        end

        it 'allows movement: north, east, south, west' do
          expect(rules.possible_moves(board, 0)).to contain_exactly('e6', 'f5', 'e4', 'd5')
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
        expect(rules.possible_moves(board, 0)).to contain_exactly('e6', 'f5')
      end
    end

    context 'no fences, many pawns'
    context 'some fences, many pawns'
  end
end
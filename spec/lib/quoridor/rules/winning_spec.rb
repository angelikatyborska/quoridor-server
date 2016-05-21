require_relative '../../../../lib/quoridor/rules/winning'
require_relative '../../../../lib/quoridor/board'

RSpec.describe(Quoridor::Rules::Winning) do
  let(:rules) { Quoridor::Rules::Winning }
  let(:board) { Quoridor::Board.new }

  describe '#has_won?' do
    context 'pawns on their goal rows/columns' do
      before(:each) do
        board.add_pawn('b1')
        board.add_pawn('e9')
        board.add_pawn('i3')
        board.add_pawn('a9')
      end

      it 'returns true' do
        expect(rules.has_won?(board, 0)).to be true
        expect(rules.has_won?(board, 1)).to be true
        expect(rules.has_won?(board, 2)).to be true
        expect(rules.has_won?(board, 3)).to be true
      end
    end
  end
end
module Quoridor
  class Rules
    def possible_moves(board, pawnNumber)
      pawn = board.pawns[pawnNumber]
      board.neighboring_squares(pawn).reject {|square| board.fence?(square, pawn)}
    end
  end
end
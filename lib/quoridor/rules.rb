module Quoridor
  class Rules
    def possible_moves(board, pawnNumber)
      pawn = board.pawns[pawnNumber]
      board.neighboring_squares(pawn)
    end
  end
end
module Quoridor
  class Rules
    def possible_moves(board, pawn_number)
      pawn = board.pawns[pawn_number]
      possible_moves = board.adjacent_squares(pawn)
      possible_moves.reject! {|square| board.fence?(square, pawn)}
      possible_moves.map! do |square|
        if board.pawns.include?(square)
          direction = board.direction(pawn, square)
          board.send(direction, square)
        else
          square
        end
      end
    end
  end
end
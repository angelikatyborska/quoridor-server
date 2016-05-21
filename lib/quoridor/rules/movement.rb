module Quoridor
  module Rules
    module Movement
      class << self
        def possible_movements(board, pawn_number)
          pawn = board.pawns[pawn_number]
          possible_moves = can_move_to_adjacent_squares(board, pawn)
          possible_moves = cannot_jump_over_fences(board, pawn, possible_moves)

          possible_moves = cannot_move_to_occupied_squares(board, pawn, possible_moves)
          possible_moves.flatten
        end

        private

        def can_move_to_adjacent_squares(board, pawn)
          board.adjacent_squares(pawn)
        end

        def cannot_jump_over_fences(board, pawn, moves)
          moves.reject {|square| board.fence?(square, pawn)}
        end

        def cannot_move_to_occupied_squares(board, pawn, moves)
          moves.map do |square|
            if board.pawn?(square)
              tries_to_move_behind_other_pawn(board, pawn, square)
            else
              [square]
            end
          end
        end

        def tries_to_move_behind_other_pawn(board, pawn, other_pawn)
          direction = board.direction(pawn, other_pawn)
          jump_over = board.send(direction, other_pawn)
          if can_move?(board, other_pawn, jump_over)
            [jump_over]
          else
            tries_to_move_to_the_side(board, other_pawn, direction)
          end
        end

        def tries_to_move_to_the_side(board, original_square, original_direction)
          directions = board.directions_in_opposite_orientation(original_direction)
          possible_moves = directions.map {|direction| board.send(direction, original_square)}
          possible_moves = cannot_jump_over_fences(board, original_square, possible_moves)
          possible_moves.reject {|square| board.pawn?(square)}
        end

        def can_move?(board, from, to)
          !(board.fence?(from, to) || board.pawn?(to))
        end
      end
    end
  end
end
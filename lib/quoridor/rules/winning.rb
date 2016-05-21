module Quoridor
  module Rules
    module Winning
      class << self
        PLAYERS = [
          {starting_position: 'e9', goal: 'southmost_row?'},
          {starting_position: 'e1', goal: 'northmost_row?'},
          {starting_position: 'a5', goal: 'eastmost_column?'},
          {starting_position: 'i5', goal: 'westmost_column?'}
        ]

        def has_won?(board, player_number)
          pawn = board.pawns[player_number]
          goal = PLAYERS[player_number][:goal]
          board.send(goal, pawn)
        end
      end
    end
  end
end
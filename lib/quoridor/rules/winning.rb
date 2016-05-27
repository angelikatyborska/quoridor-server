require_relative 'players'

module Quoridor
  module Rules
    module Winning
      class << self
        def has_won?(board, player_number)
          pawn = board.pawns[player_number]
          board.send("#{goal(player_number)}?", pawn)
        end

        def goal(player_number)
          Quoridor::Rules::Players::PLAYERS[player_number][:goal]
        end
      end
    end
  end
end
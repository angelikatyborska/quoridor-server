module Quoridor
  class Game
    def initialize(players)
      unless [2,4].include?(players.length)
        fail ArgumentError, 'Only 2 or 4 players per game allowed'
      end

      @players = players
    end
  end
end
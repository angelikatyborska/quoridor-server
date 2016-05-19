require_relative 'player'

module Quoridor
  class Lobby
    attr_reader :players

    def initialize
      @players = {}
    end

    def add_player(websocket)
      player = Player.new(websocket)
      @players[player.id] = player
    end

    def remove_player(id)
      @players.delete(id)
    end
  end
end
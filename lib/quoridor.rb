require_relative 'quoridor/player'

class Quoridor
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
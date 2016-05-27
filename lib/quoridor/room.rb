require_relative 'errors'
require_relative 'game'

module Quoridor
  class Room
    attr_reader :id
    attr_reader :players

    # TODO: add a description/name
    def initialize(owner, capacity)
      @capacity = capacity
      @players = []
      @owner = owner
      @id = SecureRandom.base64 # TODO: possible id collisions
    end

    def to_s
      "Room #{id} (capacity #{@capacity}) with players: #{players.map(&:to_s).join(', ')}"
    end

    def state
      {
        capacity: @capacity,
        players: @players,
        owner: @owner,
        id: @id,
        game: @game ? @game.state : nil
      }
    end

    def join(player)
      fail 'Room is full' if @players.length >= @capacity
      @players << player
    end

    def leave(player)
      @players.delete(player)

      # TODO: force end game
    end

    def start_game(player)
      fail 'Only owner can start the game' unless player == @owner
      fail 'Not enough players' unless start_game?

      @game = Quoridor::Game.new(@players.map(&:nickname))
    end

    def move(player, move)
      fail 'Game is not started' unless @game
      fail 'Game has ended' if @winner

      @game.move(@players.index(player), move)
      puts "Player #{@players.index(player)} move: #{move}"
    end

    def start_game?
      @capacity == @players.length
    end
  end
end
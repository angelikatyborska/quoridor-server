require_relative '../errors'
require_relative '../game'

module Quoridor
  module Lobby
    class Room
      attr_reader :id
      attr_reader :players
      attr_reader :game
      attr_reader :owner
      attr_reader :capacity

      # TODO: add a description/name
      # TODO: add invitation only joining
      def initialize(owner, capacity)
        @capacity = capacity
        @players = []
        @owner = owner
        @id = SecureRandom.base64 # TODO: possible id collisions
        @game = nil
      end

      def to_s
        "Room #{id} (capacity #{capacity}) with players: #{players.map(&:to_s).join(', ')}"
      end

      def state
        {
          capacity: capacity,
          players: players,
          owner: owner,
          id: id,
          game: game ? game.state : nil
        }
      end

      def join(player)
        fail 'Room is full' if players.length >= capacity
        fail "#{player} is already in the room" if players.include?(player)
        @players << player
      end

      def leave(player)
        @players.delete(player)

        # TODO: force end game
      end

      def start_game(player)
        fail 'Only owner can start the game' unless player == owner
        fail 'Not enough players' unless start_game?

        @game = Game::Game.new(players.map(&:nickname))
      end

      def start_game?
        capacity == players.length
      end

      def move(player, move)
        fail 'Game has not started yet' unless game

        game.move(players.index(player), move)
      end
    end
  end
end
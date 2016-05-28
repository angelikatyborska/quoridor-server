require_relative 'player'
require_relative 'room'
require_relative '../errors'
require 'JSON'

# Has to be thread safe
module Quoridor
  module Lobby
    class ReceptionDesk
      attr_reader :players
      attr_reader :rooms

      # TODO: refactor, write tests
      def initialize
        @players = []
        @rooms = []
        @players_ids_to_rooms_ids = {}
      end

      def players_in_lobby
        @players.reject { |player| @players_ids_to_rooms_ids.include?(player.id) }
      end

      def players_not_playing
        @players.reject { |player| @players_ids_to_rooms_ids.include?(player.id) && get_room(player).state.game }
      end

      def request(player, json_message)
        begin
          message = JSON.parse(json_message)
        rescue JSON::ParserError => e
          MalformedMessage.new(json_message, e.message)
        end

        puts message

        unless message['type'] && message['data']
          fail MalformedMessage.new(message, 'must contain attributes "type" and "data"')
        end

        unless @players.include?(player) || message['type'] == 'JOIN'
          fail 'Message sent to reception desk by a player that is not in the lobby'
        end

        case message['type']
        when 'JOIN', 'LEAVE', 'CREATE_ROOM', 'JOIN_ROOM', 'LEAVE_ROOM'
          self.send(message['type'].downcase, player, message['data'])
          notify
        when 'START_GAME', 'MOVE'
          room = get_room(player)
          room.start_game(player)
        else
          # TODO: log something maybe
        end
      end

      private

      def notify
        players_not_playing.each do |player|
          player.notify(state.to_json)
        end
      end

      def self_state
        {
          players_in_lobby: players_in_lobby,
          rooms: @rooms.map(&:state)
        }
      end

      def join(player, data)
        nickname = data['nickname']

        if !nickname || @players.any? { |player| player.nickname == nickname }
          fail 'An unique nickname is required'
        end

        if player.nickname
          fail 'Cannot change nicknames'
        end

        player.introduce_yourself(nickname)
        @players << player
      end


      def leave(player)
        # TODO: leave room first
        @players.delete(player)
        notify
      end

      def create_room(player, data)
        unless data['capacity']
          fail MalformedMessage.new(data, 'capacity cannot be blank')
        end

        room = Room.new(player, data['capacity'].to_i)
        @rooms << room
        put_player_in_room(player, room)
      end

      def join_room(player, data)
        unless room = @rooms.find { |room| room.id == data['room_id'] }
          fail MalformedMessage.new(data, "room with id #{data['room_id']} not found")
        end

        if @players_ids_to_rooms_ids[player.id]
          fail MalformedMessage.new(data, "player already inside room #{@players_ids_to_rooms_ids[player.id].id}")
        end

        put_player_in_room(player, room)
      end

      def leave_room(player, data)
        unless room = @rooms.find { |room| room.id == data['room_id'] }
          fail MalformedMessage.new(data, "room with id #{room.id} not found")
        end

        unless @players_ids_to_rooms_ids[player.id] == room.id
          fail MalformedMessage.new(data, "player is not inside room #{data['room_id']}}")
        end

        room.leave(player)
        @players_ids_to_rooms_ids.delete(player.id)
        @rooms.delete(room) if room.players.length <= 0
      end

      def put_player_in_room(player, room)
        room.join(player)
        @players_ids_to_rooms_ids[player.id] = room.id
      end

      def get_room(player)
        rooms.find { |room| room.id == @players_ids_to_rooms_ids[player.id] }
      end
    end
  end
end
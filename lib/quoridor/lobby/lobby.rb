require_relative 'player'
require_relative 'room'
require_relative 'errors'
require 'JSON'

# Has to be thread safe
module Quoridor
  module Lobby
    class Lobby
      attr_reader :players
      attr_reader :rooms

      # TODO: refactor, write tests
      def initialize
        @players = []
        @rooms = []
        @players_ids_to_rooms_ids = {}
        @notification_queues = Hash.new { |hash, key| hash[key] = [] }
      end

      def players_in_lobby
        @players.reject { |player| @players_ids_to_rooms_ids.include?(player.id) }
      end

      def add_player(websocket)
        player = Player.new(websocket)
        @players << player
        @notification_queues['main'] << player
        notify('main', self_state)
        player
      end

      def remove_player(player)
        @players.delete(player)
        @notification_queues['main'].delete(player)
        notify('main', self_state)
      end

      def reception_desk(player, json_message)
        message = JSON.parse(json_message)

        puts message

        unless @players.include?(player)
          fail 'Message send to reception desk by a player that is not in the lobby'
        end

        case message['type']
        when 'CREATE_ROOM'
          create_room(player, message['data'])
        when 'JOIN_ROOM'
          join_room(player, message['data'])
        when 'LEAVE_ROOM'
          leave_room(player, message['data'])
        when 'START_GAME'
          start_game(player)
        when 'MOVE'
          move(player, message['data'])
        else
          # TODO: log something maybe
        end
      end

      private

      def notify(queue, message)
        @notification_queues[queue].each do |player|
          player.websocket.send(message.to_json)
        end
      end

      def self_state
        {
          players_in_lobby: players_in_lobby,
          rooms: @rooms
        }
      end

      def create_room(player, data)
        unless data['capacity']
          fail MalformedMessage.new(data, 'capacity cannot be blank')
        end

        room = Room.new(player, data['capacity'].to_i)
        @rooms << room
        put_player_in_room(player, room)
        notify('main', self_state)
        notify("room#{room.id}", {room: room.state})
      end

      def join_room(player, data)
        unless room = @rooms.find { |room| room.id == data['room_id'] }
          fail MalformedMessage.new(data, "room with id #{data['room_id']} not found")
        end

        if @players_ids_to_rooms_ids[player.id]
          fail MalformedMessage.new(data, "player already inside room #{@players_ids_to_rooms_ids[player.id].id}")
        end

        put_player_in_room(player, room)
        notify('main', self_state)
        notify("room#{room.id}", {room: room.state})
      end

      def leave_room(player, data)
        unless room = @rooms.find { |room| room.id == data['room_id'] }
          fail MalformedMessage.new(data, "room with id #{room.id} not found")
        end

        unless @players_ids_to_rooms_ids[player.id] == room.id
          fail MalformedMessage.new(data, "player is not inside room #{data['room_id']}}")
        end

        @notification_queues["room#{room.id}"].delete(player)
        room.leave(player)
        @players_ids_to_rooms_ids.delete(player.id)
        @notification_queues['main'] << player
        room.id
        notify('main', self_state)
        notify("room#{room.id}", {room: room.state})
      end

      def start_game(player)
        room = @rooms.find { |room| room.id == @players_ids_to_rooms_ids[player.id] }
        room.start_game(player)
        notify("room#{room.id}", {room: room.state})
      end

      def move(player, data)
        room = @rooms.find { |room| room.id == @players_ids_to_rooms_ids[player.id] }
        room.move(player, data['move'])
        notify("room#{room.id}", {room: room.state})
      end

      def put_player_in_room(player, room)
        @notification_queues['main'].delete(player)

        room.join(player)
        @players_ids_to_rooms_ids[player.id] = room.id
        room.id

        @notification_queues["room#{room.id}"] << player
      end
    end
  end
end
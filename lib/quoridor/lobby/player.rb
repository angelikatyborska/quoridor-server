module Quoridor
  module Lobby
    class Player
      attr_reader :id
      attr_accessor :nickname
      attr_accessor :websocket

      def initialize(websocket)
        @id = SecureRandom.base64
        @nickname = 'guest' + @id
        @websocket = websocket
      end

      def to_s
        "Player #{id[0..5]}"
      end

      def inspect
        to_s
      end
    end
  end
end
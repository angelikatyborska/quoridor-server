module Quoridor
  module Lobby
    class Player
      attr_reader :id
      attr_accessor :nickname
      attr_accessor :websocket

      def initialize(websocket)
        @id = SecureRandom.base64
        @nickname = nil
        @websocket = websocket
      end

      def notify(message)
        @websocket.send(message)
      end

      def introduce_self(nickname)
        @nickname = nickname
      end

      def to_s
        nickname
      end

      def to_h
        { id: id, nickname: nickname }
      end
    end
  end
end
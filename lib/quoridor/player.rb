module Quoridor
  class Player
    attr_reader :id
    attr_accessor :nickname
    attr_accessor :websocket

    def initialize(websocket)
      @id = SecureRandom.base64 # TODO: possible id collisions
      @nickname = 'guest' + @id
      @websocket = websocket
    end

    def to_s
      "Player #{id}"
    end

    def inspect
      to_s
    end

    # TODO: overwrite inspect or to_s
  end
end
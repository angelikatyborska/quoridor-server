class Player
  attr_reader :id
  attr_accessor :nickname

  def initialize(websocket)
    @id = SecureRandom.base64
    @nickname = 'guest'
    @websocket = websocket
  end
end
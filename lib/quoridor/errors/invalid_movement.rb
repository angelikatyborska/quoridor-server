require_relative 'error'

module Quoridor
  class InvalidMovement < Quoridor::Error
    def initialize(player, square)
      super("Invalid movement #{square} for player #{player}")
    end
  end
end
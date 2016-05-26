require_relative 'error'

module Quoridor
  class OutOfTurn < Quoridor::Error
    def initialize(player)
      super("It is not player #{player}'s turn")
    end
  end
end
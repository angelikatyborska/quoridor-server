require_relative 'error'

module Quoridor
  class InvalidNumberOfPlayers < Quoridor::Error
    def initialize
      super('Only 2 or 4 players per game allowed')
    end
  end
end
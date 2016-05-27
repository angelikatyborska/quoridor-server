require_relative 'error'
require_relative '../rules/players'

module Quoridor
  class InvalidNumberOfPlayers < Quoridor::Error
    def initialize(number)
      super("Invalid number of players #{number}, allowed: #{Quoridor::Rules::Players::ALLOWED_NUMBERS_OF_PLAYERS.join(', ')}")
    end
  end
end
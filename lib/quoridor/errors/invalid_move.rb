require_relative 'error'

module Quoridor
  class InvalidMove < Quoridor::Error
    def initialize(move)
      super("Invalid move #{move}")
    end
  end
end
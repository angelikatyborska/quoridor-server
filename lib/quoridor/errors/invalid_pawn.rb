require_relative 'error'

module Quoridor
  class InvalidPawn < StandardError
    def initialize(index)
      super("Invalid pawn #{index}")
    end
  end
end
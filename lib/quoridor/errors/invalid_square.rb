require_relative 'error'

module Quoridor
  class InvalidSquare < Quoridor::Error
    def initialize(square)
      super("Invalid square #{square}")
    end
  end
end
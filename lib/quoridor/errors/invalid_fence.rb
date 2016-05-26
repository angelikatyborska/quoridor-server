require_relative 'error'

module Quoridor
  class InvalidFence < Quoridor::Error
    def initialize(fence)
      super("Invalid fence #{fence}")
    end
  end
end
require_relative 'error'

module Quoridor
  class InvalidFencePlacement < Quoridor::Error
    def initialize(fence)
      super("Invalid fence placement #{fence}")
    end
  end
end
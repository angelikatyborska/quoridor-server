module Quoridor
  class MalformedMessage < Quoridor::Error
    def initialize(hash_message, cause)
      super("Malformed message #{hash_message}: #{cause}")
    end
  end
end
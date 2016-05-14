require 'rspec/expectations'

RSpec::Matchers.define :detect_invalid_pawn do |expected|
  supports_block_expectations

  match do |actual|
    begin
      actual.call
      return false
    rescue ArgumentError => e
      return e.message.match(/\APawn with index .* does not exist\z/)
    end
  end

  failure_message do |actual|
    "expected that #{actual} would detect an invalid pawn"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not detect an invalid pawn"
  end

  description do
    "detect a pawn that was not placed on the board"
  end
end
require 'rspec/expectations'
require_relative '../../../lib/quoridor/errors'

RSpec::Matchers.define :detect_invalid_pawn do |expected|
  supports_block_expectations

  match do |actual|
    begin
      actual.call
      return false
    rescue Quoridor::InvalidPawn => e
      return e.message.match(/\AInvalid pawn .*\z/)
    end
  end

  failure_message do |actual|
    "expected that #{actual} would detect an invalid pawn"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not detect an invalid pawn"
  end

  description do
    'detect a pawn that was not placed on the board'
  end
end
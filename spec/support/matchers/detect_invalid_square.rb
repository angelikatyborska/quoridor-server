require 'rspec/expectations'

RSpec::Matchers.define :detect_invalid_square do |expected|
  supports_block_expectations

  match do |actual|
    begin
      actual.call
      return false
    rescue ArgumentError => e
      return e.message.match(/\AInvalid square .*, must be between a1 and i9\z/)
    end
  end

  failure_message do |actual|
    "expected that #{actual} would detect an invalid square"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not detect an invalid square"
  end

  description do
    "detect square outside of a1-i9 range"
  end
end
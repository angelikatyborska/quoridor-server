require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  track_files 'lib/**/*.rb'
  add_group 'Lobby', %w(lib/quoridor/lobby lib/quoridor/lobby.rb)
  add_group 'Game', %w(lib/quoridor/game lib/quoridor/game.rb)
  add_group 'Rules', %w(lib/quoridor/rules lib/quoridor/rules.rb)
  add_group 'Errors', %w(lib/quoridor/errors lib/quoridor/errors.rb)
end

RSpec.configure do |config|

  Dir['./spec/support/**/*.rb'].sort.each { |f| require f}

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
end

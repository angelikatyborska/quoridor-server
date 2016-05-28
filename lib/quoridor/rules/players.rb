module Quoridor
  module Rules
    module Players
      PLAYERS = [
        {starting_position: 'e9', goal: 'southmost_row'},
        {starting_position: 'e1', goal: 'northmost_row'},
        {starting_position: 'a5', goal: 'eastmost_column'},
        {starting_position: 'i5', goal: 'westmost_column'}
      ]

      ALLOWED_NUMBERS_OF_PLAYERS = [2, 4]
      FENCE_LIMIT_PER_PLAYERS_NUMBER = {2 => 10, 4 => 5}
    end
  end
end
require_relative '../rules/winning'
require_relative '../board'
require_relative '../path_finder'

module Quoridor
  module Rules
    module FencePlacement
      class << self
        ALL_POSSIBLE_FENCE_PLACEMENTS = Quoridor::Board::COLUMNS[0..-2].each_with_object([]) do |column, all|
          Quoridor::Board::ROWS[0..-2].each do |row|
            Quoridor::Board::ORIENTATIONS.each do |orientation|
              all << "#{column}#{row}#{orientation}"
            end
          end
        end

        def correct_fence_placement?(board, fence)
          possible_fence_placements(board).include?(fence)
        end

        def possible_fence_placements(board)
          possible_placements = cannot_place_overlapping(board, ALL_POSSIBLE_FENCE_PLACEMENTS)
          cannot_cut_off_path_to_goals(board, possible_placements)
        end

        private

        def cannot_place_overlapping(board, placements)
          placements.select do |placement|
            board.possible_fence_placement?(placement)
          end
        end

        def cannot_cut_off_path_to_goals(board, placements)
          return placements if placements.length <= 1

          placements.reject do |placement|
            future_board = board.deep_clone
            future_board.add_fence(placement)
            path_finder = Quoridor::PathFinder.new(future_board)

            future_board.pawns.each_with_index.any? do |pawn, index|
              goal = Quoridor::Rules::Winning.goal(index)
              goals = future_board.send(goal)
              !path_finder.find(pawn, goals)
            end
          end
        end
      end
    end
  end
end
module Quoridor
  class PathFinder
    def initialize(board)
      @board = board
    end

    def find(start_square, target_squares)
      distances = {}
      target_squares.each { |square| distances[square] = 0 }
      target_squares.each { |square| calculate_neighboring_distances(square, distances) }
      collect_path(start_square, distances)
    end

    def calculate_neighboring_distances(square, distances)
      new_distance = distances[square] + 1

      @board.neighboring_squares(square).each do |neighbor|
        current_distance = distances[neighbor]

        if current_distance.nil? || current_distance > new_distance
          unless @board.fence?(square, neighbor)
            distances[neighbor] = new_distance
            calculate_neighboring_distances(neighbor, distances)
          end
        end
      end
    end

    def collect_path(target, distances)
      return nil if distances[target].nil?

      collect_path_partial(target, distances)
    end

    private

    def collect_path_partial(square, distances)
      return [] if distances[square] == 0

      @board.neighboring_squares(square).each do |neighbor|
        if distances[neighbor] && distances[neighbor] == distances[square] - 1 && !@board.fence?(neighbor, square)
          return [neighbor] + collect_path(neighbor, distances)
        end
      end
    end
  end
end
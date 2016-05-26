module Quoridor
  class PathFinder
    def initialize(board)
      @board = board
    end

    def find(start_square, target_squares)
      open = {}
      closed = {}

      fill_data(start_square, :start, target_squares, open)
      current_square = process_square(open, closed)

      while current_square && !target_squares.include?(current_square[0])
        fill_neighbors_data(current_square, target_squares, open, closed)
        current_square = process_square(open, closed)
      end

      collect_path(target_squares, closed)
    end

    private

    def fill_neighbors_data(current_square, target_squares, open, closed)
      @board.adjacent_squares(current_square[0]).each do |square|
        unless closed[square] || open[square] || @board.fence?(square, current_square[0])
          fill_data(square, current_square[0], target_squares, open)
        end
      end
    end

    def fill_data(square, parent, target_squares, open)
      open[square]= { parent: parent }
      fill_costs(square, target_squares, open)
    end

    def process_square(open, closed)
      current_square = pop_min(open)
      closed.merge!([current_square].to_h) if current_square
      current_square
    end

    def fill_costs(current_square, target_squares, costs)
      parent = costs[costs[current_square][:parent]]

      costs[current_square][:h] = heuristic(target_squares, current_square)
      costs[current_square][:g] = (parent ? parent[:g] : 0) + 1
      costs[current_square][:f] = costs[current_square][:h] + costs[current_square][:g]
    end

    def collect_path(target_squares, closed)
      closed_target_squares = closed.select { |square, costs| target_squares.include?(square) }
      return nil if closed_target_squares.empty?

      parent = closed_target_squares.min_by { |square, costs| costs[:g] }[0]
      path = [parent]

      while (parent = closed[parent][:parent]) && parent != :start
        path << parent
      end

      path.reverse[1..-1]
    end

    def pop_min(open)
      min = open.min_by { |square, costs| costs[:f] }
      open.delete(min[0]) if min
      min
    end

    def heuristic(target_squares, current_square)
      target_squares.map { |target| taxicab_metric(target, current_square) }.min
    end

    def taxicab_metric(a, b)
      (a[0].ord - b[0].ord).abs + (a[1].ord - b[1].ord).abs
    end
  end
end

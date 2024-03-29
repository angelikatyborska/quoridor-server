require_relative '../errors'

module Quoridor
  module Game
    class Board
      COLUMNS = %w(a b c d e f g h i)
      ROWS = %w(9 8 7 6 5 4 3 2 1)
      ORIENTATIONS = %w(h v)
      DIRECTIONS = %i(north south east west)

      attr_reader :fences, :pawns

      # TODO: extract Square and Fence objects!!!
      # TODO: start using Reek

      def initialize
        @fences = []
        @pawns = []
      end

      def add_pawn(square)
        put_pawn(@pawns.length, square)
      end

      def move_pawn(index, square)
        validate_pawn(index)
        put_pawn(index, square)
      end

      def add_fence(fence)
        validate_fence(fence)
        validate_fence_placement(fence)
        @fences << fence
      end

      def fence?(square1, square2)
        validate_square(square1)
        validate_square(square2)

        @fences.any? { |fence| fence_between?(fence, square1, square2) }
      end

      def pawn?(square)
        validate_square(square)
        pawns.include?(square)
      end

      def possible_fence_placement?(fence)
        validate_fence(fence)
        begin
          validate_fence_placement(fence)
          true
        rescue Quoridor::InvalidFence
          false
        end
      end

      def adjacent_squares(square)
        validate_square(square)
        DIRECTIONS.map { |direction| self.send(direction, square) }.compact
      end

      def direction(square1, square2)
        validate_square(square1)
        validate_square(square2)

        DIRECTIONS.each do |direction|
          if self.send(direction, square1) == square2
            return direction
          end
        end

        fail Quoridor::InvalidSquare.new("#{square2}: not adjacent to #{square1}")
      end

      def directions_in_opposite_orientation(direction)
        index = DIRECTIONS.index(direction)
        index > 1 ? DIRECTIONS[0..1] : DIRECTIONS[2..3]
      end

      def east(square)
        square_relative_to(square, [1, 0])
      end

      def west(square)
        square_relative_to(square, [-1, 0])
      end

      def north(square)
        square_relative_to(square, [0, -1])
      end

      def south(square)
        square_relative_to(square, [0, 1])
      end

      def westmost_column
        ROWS.map{|row| "#{COLUMNS.first}#{row}"}
      end

      def westmost_column?(square)
        validate_square(square)
        square[0] == COLUMNS.first
      end

      def eastmost_column
        ROWS.map{|row| "#{COLUMNS.last}#{row}"}
      end

      def eastmost_column?(square)
        validate_square(square)
        square[0] == COLUMNS.last
      end

      def northmost_row
        COLUMNS.map{|column| "#{column}#{ROWS.first}"}
      end

      def northmost_row?(square)
        validate_square(square)
        square[1] == ROWS.first
      end

      def southmost_row
        COLUMNS.map{|column| "#{column}#{ROWS.last}"}
      end

      def southmost_row?(square)
        validate_square(square)
        square[1] == ROWS.last
      end

      def horizontal?(fence)
        validate_fence(fence)
        orientation(fence) == 'h'
      end

      def vertical?(fence)
        validate_fence(fence)
        orientation(fence) == 'v'
      end

      def deep_clone
        clone = self.class.new
        pawns.each { |pawn| clone.add_pawn(pawn) }
        fences.each { |fence| clone.add_fence(fence) }
        clone
      end

      private

      def square(fence)
        fence[0..1]
      end

      def orientation(fence)
        fence[2]
      end

      def put_pawn(index, square)
        validate_square(square)

        if @pawns.index(square)
          fail Quoridor::InvalidSquare.new("#{square}: already taken by pawn #{@pawns.index(square)}")
        end

        @pawns[index] = square
      end

      def validate_square(square)
        unless square.length == 2 && COLUMNS.include?(square[0]) && ROWS.include?(square[1])
          message = "#{square}, must be between #{COLUMNS.first}#{ROWS.first} and #{COLUMNS.last}#{ROWS.last}"
          fail Quoridor::InvalidSquare.new(message)
        end
      end

      def validate_fence(fence)
        validate_square(square(fence))

        unless ORIENTATIONS.include?(orientation(fence)) && fence.length == 3
          fail Quoridor::InvalidFence.new(fence)
        end
      end

      def validate_fence_placement(fence)
        if southmost_row?(square(fence)) || eastmost_column?(square(fence))
          fail Quoridor::InvalidFence.new("#{fence}: out of border bounds")
        end

        @fences.each do |other_fence|
          if fences_overlapping?(fence, other_fence)
            fail Quoridor::InvalidFence.new("#{fence}: overlapping #{other_fence}")
          end
        end
      end

      def validate_pawn(index)
        unless pawns[index]
          fail Quoridor::InvalidPawn.new(index)
        end
      end

      def fence_between?(fence, square1, square2)
        return false unless adjacent_squares(square1).include?(square2)

        square1, square2 = sort_squares(square1, square2)

        if square1[0] == square2[0]
          (square(fence) == square1 || square(fence) == west(square1)) && horizontal?(fence)
        else
          (square(fence) == square1 || square(fence) == north(square1)) && vertical?(fence)
        end
      end

      def fences_overlapping?(fence1, fence2)
        return true if square(fence1) == square(fence2)

        if orientation(fence1) == orientation(fence2)
          if horizontal?(fence1)
            return east(square(fence1)) == square(fence2) || west(square(fence1)) == square(fence2)
          else
            return north(square(fence1)) == square(fence2) || south(square(fence1)) == square(fence2)
          end
        end

        false
      end

      def sort_squares(square1, square2)
        # sorting from top left (a9) to bottom right (i1)
        original_order = [square1, square2]
        reserved_order = [square2, square1]
        columns_ascending = square1[0] < square2[0]
        columns_equal = square1[0] == square2[0]
        rows_descending = square1[1] > square2[1]

        if columns_ascending
          original_order
        else
          if columns_equal
            if rows_descending
              original_order
            else
              reserved_order
            end
          else
            reserved_order
          end
        end
      end

      def square_relative_to(square, coordinates)
        validate_square(square)
        column = COLUMNS.index(square[0]) + coordinates[0]
        row = ROWS.index(square[1]) + coordinates[1]

        return nil unless (0...COLUMNS.length).include?(column)
        return nil unless (0...ROWS.length).include?(row)

        "#{COLUMNS[column]}#{ROWS[row]}"
      end
    end
  end
end
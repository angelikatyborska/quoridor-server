class Board
  COLUMNS = %w(a b c d e f g h i)
  ROWS = %w(1 2 3 4 5 6 7 8 9)
  ORIENTATIONS = %w(h v)

  attr_reader :fences, :pawns

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

  def neighboring_squares(square)
    directions = %w(north east south west)
    directions.map { |direction| self.send(direction, square) }.compact
  end

  def east(square)
    square_relative_to(square, [1, 0])
  end

  def west(square)
    square_relative_to(square, [-1, 0])
  end

  def north(square)
    square_relative_to(square, [0, 1])
  end

  def south(square)
    square_relative_to(square, [0, -1])
  end

  def first_column?(square)
    square[0] == COLUMNS.first
  end

  def last_column?(square)
    square[0] == COLUMNS.last
  end

  def first_row?(square)
    square[1] == ROWS.first
  end

  def last_row?(square)
    square[1] == ROWS.last
  end

  def horizontal?(fence)
    orientation(fence) == 'h'
  end

  def vertical?(fence)
    orientation(fence) == 'v'
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
      fail ArgumentError, "Square #{square} is already taken by pawn #{@pawns.index(square)}"
    end

    @pawns[index] = square
  end

  def validate_square(square)
    unless square.length == 2 && COLUMNS.include?(square[0]) && ROWS.include?(square[1])
      fail ArgumentError, "Invalid square #{square}, "\
      "must be between #{COLUMNS.first}#{ROWS.first} "\
      "and #{COLUMNS.last}#{ROWS.last}"
    end
  end

  def validate_fence(fence)
    validate_square(square(fence))

    unless ORIENTATIONS.include?(orientation(fence)) && fence.length == 3
      fail ArgumentError, "Invalid fence #{fence}"
    end
  end

  def validate_fence_placement(fence)
    if last_row?(square(fence)) || last_column?(square(fence))
      fail ArgumentError, 'Cannot place a fence outside of the board'
    end

    if @fences.any? { |other_fence| fences_overlapping?(fence, other_fence) }
      fail ArgumentError, 'Cannot place a fence on another fence'
    end
  end

  def validate_pawn(index)
    unless pawns[index]
      fail ArgumentError, "Pawn with index #{index} does not exist"
    end
  end

  def fence_between?(fence, square1, square2)
    return false unless neighboring_squares(square1).include?(square2)

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
class Board
  COLUMNS = ('a'..'i').to_a
  ROWS = ('1'..'9').to_a

  attr_reader :fences, :players

  def initialize
    @fences = []
    @players = []
  end

  def add_player(square)
    validate_square(square)
    @players << square
  end

  def move_player(index, square)
    validate_player(index)
    validate_square(square)
    # check if does not collide with other player
    @players[index] = square
  end

  def add_fence(designation)
    validate_designation(designation)
    # check if physically possible
    @fences << designation
  end

  private

  def validate_square(square)
    unless square.length == 2 && COLUMNS.include?(square[0]) && ROWS.include?(square[1])
      fail ArgumentError, "Invalid square #{square}, "\
      "must be between #{COLUMNS.first}#{ROWS.first} "\
      "and #{COLUMNS.last}#{ROWS.last}"
    end
  end

  def validate_designation(designation)
    validate_square(designation[0..1])

    unless %w(h v).include?(designation[2]) && designation.length == 3
      fail ArgumentError, "Invalid designation #{designation}"
    end
  end

  def validate_player(index)
    unless players[index]
      fail ArgumentError, "Player with index #{index} does not exist"
    end
  end
end
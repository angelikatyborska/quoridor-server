require_relative 'board'
require_relative 'rules'

module Quoridor
  class Game
    attr_reader :turn

    def initialize(players)
      unless [2,4].include?(players.length)
        fail ArgumentError, 'Only 2 or 4 players per game allowed'
      end

      @players = players
      @board = Quoridor::Board.new
      @players.length.times { |n| @board.add_pawn(Quoridor::Rules::Winning::PLAYERS[n][:starting_position]) }
      @turn = 0
    end

    def move(player, move)
      fail "It is not player's #{player} turn" if turn != player
      make_a_move = if move.length == 2
        Proc.new { @board.move_pawn(player, move) }
      elsif move.length == 3
        Proc.new { @board.add_fence(move) }
      else
        fail ArgumentError, "Invalid move #{move}"
      end

      begin
        make_a_move.call
        increment_turn
      rescue ArgumentError => e
        fail ArgumentError, "Invalid move #{move}: #{e.message}"
      end
    end

    private

    def increment_turn
      @turn = (@turn + 1) % @players.count
    end
  end
end
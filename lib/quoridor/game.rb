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
      fail ArgumentError, "It is not player #{player}'s turn" if turn != player

      make_a_move = if move.length == 2
        if Quoridor::Rules::Movement.correct_movement?(@board, player, move)
          Proc.new { @board.move_pawn(player, move) }
        else
          fail ArgumentError, "Invalid movement #{move} for player #{player}"
        end
      elsif move.length == 3
        if Quoridor::Rules::FencePlacement.correct_fence_placement?(@board, move)
          Proc.new { @board.add_fence(move) }
        else
          fail ArgumentError, "Invalid fence placement #{move}"
        end
      else
        fail ArgumentError, "Invalid move #{move}"
      end

      begin
        make_a_move.call
        increment_turn
        Quoridor::Rules::Winning.has_won?(@board, player) ? { winner: player } : {}
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
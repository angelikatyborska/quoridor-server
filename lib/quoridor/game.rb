require_relative 'board'
require_relative 'rules'
require_relative 'errors'

module Quoridor
  class Game
    attr_reader :turn

    def initialize(players)
      unless Quoridor::Rules::Players::ALLOWED_NUMBERS_OF_PLAYERS.include?(players.length)
        fail Quoridor::InvalidNumberOfPlayers.new(players.length)
      end

      @players = players
      @board = Quoridor::Board.new
      @players.length.times { |n| @board.add_pawn(Quoridor::Rules::Players::PLAYERS[n][:starting_position]) }
      @turn = 0
    end

    def state
      {
        turn: @turn,
        fences: @board.fences,
        pawns: @board.pawns,
        winner: @winner
      }
    end

    # TODO: refactor
    def move(player, move)
      fail Quoridor::OutOfTurn.new(player) if turn != player

      make_a_move = if move.length == 2
        if Quoridor::Rules::Movement.correct_movement?(@board, player, move)
          Proc.new { @board.move_pawn(player, move) }
        else
          fail Quoridor::InvalidMovement.new(player, move)
        end
      elsif move.length == 3
        if Quoridor::Rules::FencePlacement.correct_fence_placement?(@board, move)
          Proc.new { @board.add_fence(move) }
        else
          fail Quoridor::InvalidFencePlacement.new(move)
        end
      else
        fail Quoridor::InvalidMove.new(move)
      end

      begin
        make_a_move.call
        @winner = player if Quoridor::Rules::Winning.has_won?(@board, player)
        increment_turn
      rescue Quoridor::Error => e
        fail Quoridor::InvalidMove.new("#{move}: #{e.message}")
      end
    end

    private

    def increment_turn
      @turn = (@turn + 1) % @players.count
    end
  end
end
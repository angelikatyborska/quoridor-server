require_relative 'board'
require_relative 'rules'
require_relative 'errors'

module Quoridor
  class Game
    attr_reader :turn
    attr_reader :winner
    attr_reader :players
    attr_reader :fences_left

    def initialize(players)
      unless Quoridor::Rules::Players::ALLOWED_NUMBERS_OF_PLAYERS.include?(players.length)
        fail Quoridor::InvalidNumberOfPlayers.new(players.length)
      end

      @players = players
      @board = Quoridor::Board.new
      @turn = 0
      @winner = nil
      @fences_left = []
      players.length.times do |n|
        @board.add_pawn(Quoridor::Rules::Players::PLAYERS[n][:starting_position])
        @fences_left << Quoridor::Rules::Players::FENCE_LIMIT_PER_PLAYERS_NUMBER[players.length]
      end
    end

    def state
      {
        turn: turn,
        fences: @board.fences,
        pawns: @board.pawns,
        winner: winner,
        fences_left: fences_left,
        possible_moves: possible_moves,
      }
    end

    def possible_moves
      {
        fences: fences_left[turn] > 0 ? Quoridor::Rules::FencePlacement.possible_fence_placements(@board) : [],
        movements: Quoridor::Rules::Movement.possible_movements(@board, turn)
      }
    end

    def move(player, move)
      fail Quoridor::OutOfTurn.new(player) if turn != player
      fail Quoridor::Error, 'Game has already ended' if winner

      make_a_move = if movement?(move)
        movement(player, move)
      elsif fence?(move)
        fence(player, move)
      else
        fail Quoridor::InvalidMove.new(move)
      end

      begin
        make_a_move.call
        increment_turn
        @winner = player if Quoridor::Rules::Winning.has_won?(@board, player)
      rescue Quoridor::Error => e
        fail Quoridor::InvalidMove.new("#{move}: #{e.message}")
      end
    end

    private

    def movement(player, move)
      if Quoridor::Rules::Movement.correct_movement?(@board, player, move)
        Proc.new { @board.move_pawn(player, move) }
      else
        fail Quoridor::InvalidMovement.new(player, move)
      end
    end

    def fence(player, move)
      if Quoridor::Rules::FencePlacement.correct_fence_placement?(@board, move) && fences_left[player] > 0
        Proc.new  do
          @fences_left[player] -= 1
          @board.add_fence(move)
        end
      else
        fail Quoridor::InvalidFencePlacement.new(move)
      end
    end

    def fence?(move)
      move.length == 3
    end

    def movement?(move)
      move.length == 2
    end

    def increment_turn
      @turn = (turn + 1) % players.count
    end
  end
end
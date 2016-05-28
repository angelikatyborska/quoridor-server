require_relative '../../lib/quoridor/lobby/room'
require_relative '../../lib/quoridor/lobby/player'

RSpec.describe(Quoridor::Lobby::Room) do
  let(:owner) { Quoridor::Lobby::Player.new(nil) }
  let(:other_players) { [Quoridor::Lobby::Player.new(nil), Quoridor::Lobby::Player.new(nil)] }
  let(:room) { described_class.new(owner, 2) }

  describe '#state' do
    it 'returns info about the room' do
      expect(room.state[:players]).to eq([])
      expect(room.state[:owner]).to eq(owner)
      expect(room.state[:capacity]).to eq(2)
      expect(room.state[:id]).not_to be nil
    end
  end

  describe '#join' do
    it 'accepts players until full' do
      room.join(owner)
      expect(room.players).to eq([owner])

      room.join(other_players[0])
      expect(room.players).to eq([owner, other_players[0]])

      expect { room.join(other_players[1]) }.to raise_error(RuntimeError, 'Room is full') # TODO: think about what error type I want here
    end

    it 'does not allow to join twice' do
      room.join(owner)
      expect { room.join(owner) }.to raise_error(RuntimeError, "#{owner} is already in the room") # TODO: think about what error type I want here
    end
  end

  describe '#leave' do
    it 'ends the game'
  end

  describe '#start_game' do
    it 'waits for the room to be full' do
      expect { room.start_game(owner) }.to raise_error(RuntimeError, 'Not enough players') # TODO: think about what error type I want here
    end

    it 'does not allow non-owner' do
      expect { room.start_game(other_players[0]) }.to raise_error(RuntimeError, 'Only owner can start the game') # TODO: think about what error type I want here
    end

    it 'creates a game' do
      room.join(owner)
      room.join(other_players[0])
      room.start_game(owner)

      expect(room.game.class).to eq(Quoridor::Game::Game)
    end
  end

  describe '#move' do
    it 'detects that the game has not yet started' do
      expect { room.move(owner, 'e8') }.to raise_error(RuntimeError, 'Game has not started yet') # TODO: think about what error type I want here
    end

    it 'delegates the move to the game' do
      room.join(owner)
      room.join(other_players[0])
      room.start_game(owner)
      allow(room.game).to receive(:move)
      room.move(owner, 'e8')

      expect(room.game).to have_received(:move).with(0, 'e8')
    end
  end
end
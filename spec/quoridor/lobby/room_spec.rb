require_relative '../../../lib/quoridor/lobby/room'
require_relative '../../../lib/quoridor/lobby/player'

RSpec.describe(Quoridor::Lobby::Room) do
  let(:owner_ws) { spy }
  let(:other_player_ws) { spy }
  let(:owner) { Quoridor::Lobby::Player.new(owner_ws) }
  let(:other_players) { [Quoridor::Lobby::Player.new(other_player_ws), Quoridor::Lobby::Player.new(nil)] }
  let(:room) { described_class.new(owner, 2) }

  before(:each) do
    allow(owner_ws).to receive(:send)
    allow(other_player_ws).to receive(:send)
  end

  describe '#state' do
    it 'returns info about the room' do
      expect(room.state[:players]).to eq([])
      expect(room.state[:owner]).to eq(owner)
      expect(room.state[:capacity]).to eq(2)
      expect(room.state[:spots_left]).to eq(2)
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

    context 'room full' do
      before(:each) do
        room.join(owner)
        room.join(other_players[0])
      end

      it 'does not allow non-owner' do
        expect { room.start_game(other_players[0]) }.to raise_error(RuntimeError, 'Only owner can start the game') # TODO: think about what error type I want here
      end

      it 'creates a game' do
        room.start_game(owner)

        expect(room.game.class).to eq(Quoridor::Game::Game)
      end

      it 'notifies players about game state' do
        room.start_game(owner)

        state = room.game.state.to_json
        expect(owner_ws).to have_received(:send).with(state)
        expect(other_player_ws).to have_received(:send).with(state)
      end
    end
  end

  describe '#move' do
    before(:each) do
      room.join(owner)
      room.join(other_players[0])
    end

    it 'detects that the game has not yet started' do
      expect { room.move(owner, 'e8') }.to raise_error(RuntimeError, 'Game has not started yet') # TODO: think about what error type I want here
    end

    context 'with a game in progress' do
      before(:each) do
        room.start_game(owner)
      end

      it 'delegates the move to the game' do
        allow(room.game).to receive(:move)
        room.move(owner, 'e8')

        expect(room.game).to have_received(:move).with(0, 'e8')
      end

      it 'notifies players about game state' do
        state = room.game.state.to_json
        expect(owner_ws).to have_received(:send).with(state)
        expect(other_player_ws).to have_received(:send).with(state)
      end
    end
  end
end
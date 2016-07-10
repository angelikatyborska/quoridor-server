require_relative '../../../lib/quoridor/errors'
require_relative '../../../lib/quoridor/lobby/reception_desk'

# TODO: continue writing those tests
RSpec.describe(Quoridor::Lobby::ReceptionDesk) do
  let(:players_playing_ws) { spy }
  let(:players_not_playing_ws) { spy }
  let(:players_in_lobby_ws) { spy }
  let(:players_playing) { [Quoridor::Lobby::Player.new(players_playing_ws), Quoridor::Lobby::Player.new(players_playing_ws)] }
  let(:players_not_playing) { [Quoridor::Lobby::Player.new(players_not_playing_ws)] }
  let(:players_in_lobby) { [Quoridor::Lobby::Player.new(players_in_lobby_ws)] }
  let(:all_players) { players_playing + players_not_playing + players_in_lobby }
  subject(:reception_desk) { described_class.new }

  before(:each) do
    all_players.each_with_index do |player, index|
      reception_desk.request(player, {type: 'JOIN', data: {nickname: "John #{index}"}}.to_json)
    end

    playing_room_id = reception_desk.request(players_playing[0], {type: 'CREATE_ROOM', data: {capacity: 2}}.to_json)
    not_playing_room_id = reception_desk.request(players_not_playing[0], {type: 'CREATE_ROOM', data: {capacity: 2}}.to_json)

    players_playing[1..-1].each_with_index do |player, index|
      reception_desk.request(player, {type: 'JOIN_ROOM', data: {room_id: playing_room_id}}.to_json)
    end

    reception_desk.request(players_playing[0], {type: 'START_GAME', data: {}}.to_json)
  end

  describe '#players_in_lobby' do
    it 'lists all players that are not currently in rooms' do
      expect(reception_desk.players_in_lobby).to match_array(players_in_lobby)
    end
  end

  describe '#players_not_playing' do
    it 'lists all players that are not currently in the middle of a game' do
      expect(reception_desk.players_not_playing).to match_array(players_in_lobby + players_not_playing)
    end
  end

  describe '#request' do
    it 'detects a malformed json' do
      expect { reception_desk.request(all_players[0], '\{\"qwerty\"\}') }.to raise_error(Quoridor::MalformedMessage)
    end

    it 'requires keys "type" and "data"' do
      expect { reception_desk.request(all_players[0], {type: ''}.to_json) }
        .to raise_error(Quoridor::MalformedMessage)
      expect { reception_desk.request(all_players[0], {data: ''}.to_json) }
        .to raise_error(Quoridor::MalformedMessage)
      expect { reception_desk.request(all_players[0], {type: '', data: ''}.to_json) }
        .not_to raise_error(Quoridor::MalformedMessage)
    end

    describe 'JOIN' do
      it 'responds' do
        request = {type: 'JOIN', data: {nickname: 'John'}}.to_json
        response = {type: 'JOINED', data: {nickname: 'John'}}
        expect(reception_desk.request(Quoridor::Lobby::Player.new(spy), request)).to eq(response)
      end
    end

    describe 'LEAVE' do
      # TODO: implement and add to README
    end

    describe 'CREATE_ROOM' do
      # TODO: implement and add to README
    end

    describe 'JOIN_ROOM' do
      # TODO: implement and add to README
    end

    describe 'LEAVE_ROOM' do
      # TODO: implement and add to README
    end

    describe 'START_GAME' do
      # TODO: implement and add to README
    end

    describe 'MOVE' do
      # TODO: implement and add to README
    end
  end
end
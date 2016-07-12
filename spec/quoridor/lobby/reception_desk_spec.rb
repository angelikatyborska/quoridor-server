require_relative '../../../lib/quoridor/errors'
require_relative '../../../lib/quoridor/lobby/reception_desk'

# TODO: continue writing those tests
RSpec.describe(Quoridor::Lobby::ReceptionDesk) do
  let(:players_playing_ws) { spy }
  let(:players_not_playing_ws) { spy }
  let(:players_in_lobby_ws) { spy }
  let(:players_playing) { [Quoridor::Lobby::Player.new(players_playing_ws), Quoridor::Lobby::Player.new(players_playing_ws)] }
  let(:players_not_playing) { [Quoridor::Lobby::Player.new(players_not_playing_ws)] }
  let(:players_in_lobby) { [Quoridor::Lobby::Player.new(players_in_lobby_ws), Quoridor::Lobby::Player.new(players_in_lobby_ws)] }
  let(:all_players) { players_playing + players_not_playing + players_in_lobby }
  subject(:reception_desk) { described_class.new }

  before(:each) do
    all_players.each_with_index do |player, index|
      reception_desk.request(player, {type: 'JOIN', data: {nickname: "John #{index}"}}.to_json)
    end

    create_playing_room_response = reception_desk.request(
      players_playing[0],
      {type: 'CREATE_ROOM', data: {capacity: 2}}.to_json
    )

    playing_room_id = create_playing_room_response[:data][:id]

    create_not_playing_room_response = reception_desk.request(
      players_not_playing[0],
      {type: 'CREATE_ROOM', data: {capacity: 2}}.to_json
    )

    not_playing_room_id = create_not_playing_room_response[:data][:id]

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
        actual_response = reception_desk.request(Quoridor::Lobby::Player.new(spy), request)

        expect(actual_response[:type]).to eq('JOINED')
        expect(actual_response[:data][:nickname]).to eq('John')
        expect(actual_response[:data][:id]).not_to be_nil
      end
    end

    describe 'LEAVE' do
      # TODO: implement and add to README
    end

    describe 'CREATE_ROOM' do
      it 'responds' do
        request = {type: 'CREATE_ROOM', data: {capacity: 2}}.to_json
        actual_response = reception_desk.request(players_in_lobby[0], request)

        expect(actual_response[:type]).to eq('CREATED_ROOM')
        expect(actual_response[:data][:capacity]).to eq(2)
        expect(actual_response[:data][:spots_left]).to eq(1)
        expect(actual_response[:data][:id]).not_to be_nil
        expect(actual_response[:data][:owner]).to eq(players_in_lobby[0].to_h)
        expect(actual_response[:data][:players]).to eq([players_in_lobby[0].to_h])
      end
    end

    describe 'JOIN_ROOM' do
      let(:room_id) {
        create_room_request = {type: 'CREATE_ROOM', data: {capacity: 2}}.to_json
        create_room_response = reception_desk.request(players_in_lobby[0], create_room_request)
        create_room_response[:data][:id]
      }

      it 'responds' do
        request = {type: 'JOIN_ROOM', data: {room_id: room_id}}.to_json
        actual_response = reception_desk.request(players_in_lobby[1], request)

        expect(actual_response[:type]).to eq('JOINED_ROOM')
        expect(actual_response[:data][:capacity]).to eq(2)
        expect(actual_response[:data][:spots_left]).to eq(0)
        expect(actual_response[:data][:id]).not_to be_nil
        expect(actual_response[:data][:owner]).to eq(players_in_lobby[0].to_h)
        expect(actual_response[:data][:players]).to eq([players_in_lobby[0].to_h, players_in_lobby[1].to_h])
      end
    end

    describe 'LEAVE_ROOM' do
      let(:room_id) {
        create_room_request = {type: 'CREATE_ROOM', data: {capacity: 2}}.to_json
        create_room_response = reception_desk.request(players_in_lobby[0], create_room_request)
        create_room_response[:data][:id]
      }

      it 'responds' do
        request = {type: 'LEAVE_ROOM', data: {room_id: room_id}}.to_json
        actual_response = reception_desk.request(players_in_lobby[0], request)

        expect(actual_response[:type]).to eq('LEFT_ROOM')
        expect(actual_response[:data][:capacity]).to eq(2)
        expect(actual_response[:data][:spots_left]).to eq(2)
        expect(actual_response[:data][:id]).not_to be_nil
        expect(actual_response[:data][:owner]).to eq(players_in_lobby[0].to_h)
        expect(actual_response[:data][:players]).to eq([])
      end
    end

    describe 'START_GAME' do
      # TODO: implement and add to README
    end

    describe 'MOVE' do
      # TODO: implement and add to README
    end
  end
end
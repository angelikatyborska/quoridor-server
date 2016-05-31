require_relative '../../../lib/quoridor/lobby/player'

RSpec.describe(Quoridor::Lobby::Player) do
  let(:websocket) { spy }
  let(:player) { described_class.new(websocket) }

  describe '#notify' do
    it 'sends a message to the websocket' do
      allow(websocket).to receive(:send)

      player.notify('I like bananas.')

      expect(websocket).to have_received(:send).with('I like bananas.')
    end
  end

  describe '#introduce_self' do
    it 'sets the nickname' do
      player.introduce_self('John')

      expect(player.nickname).to eq('John')
    end
  end
end
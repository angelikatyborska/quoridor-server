require_relative '../../../lib/quoridor/game/path_finder'
require_relative '../../../lib/quoridor/game/board'

RSpec.describe(Quoridor::Game::PathFinder) do
  let(:board) { Quoridor::Game::Board.new }
  let(:pathfinder) { described_class.new(board) }
  let(:start) { 'e9' }
  let(:targets) { %w(a1 b1 c1 d1 e1 f1 g1 i1) }
  let(:fences) { %w() }

  subject(:shortest_path) { pathfinder.find(start, targets) }

  before(:each) do
    fences.each { |fence| board.add_fence(fence) }
  end

  context 'no fences' do
    it 'finds the shortest path' do
      expect(shortest_path).to eq(%w(e8 e7 e6 e5 e4 e3 e2 e1))
    end
  end

  context 'fences blocking all paths' do
    let(:fences) { %w(a6h c6h f6h h6h d6v e6v e5h) }

    it 'does not find a path' do
      expect(shortest_path).to be nil
    end
  end

  context 'fences not blocking all paths' do
    let(:fences) { %w(b9h d9h f9h h9h a8v a6h ) }

    it 'finds the shortest path' do
      expect(shortest_path).to eq(%w(d9 c9 b9 a9 a8 a7 a6 b6 c6 c5 c4 c3 c2 c1))
    end
  end

  context 'starting at the target' do
    let(:start) { 'a1' }

    it 'finds the shortest path' do
      expect(shortest_path).to eq([])
    end
  end
end
require_relative '../../../../lib/quoridor/rules/fence_placement'

RSpec.describe(Quoridor::Rules::FencePlacement) do
  let(:board) { Quoridor::Board.new }
  let(:rules) { described_class }
  let(:all_possible_fences) { %w(
    a9h b9h c9h d9h e9h f9h g9h h9h
    a9v b9v c9v d9v e9v f9v g9v h9v

    a8h b8h c8h d8h e8h f8h g8h h8h
    a8v b8v c8v d8v e8v f8v g8v h8v

    a7h b7h c7h d7h e7h f7h g7h h7h
    a7v b7v c7v d7v e7v f7v g7v h7v

    a6h b6h c6h d6h e6h f6h g6h h6h
    a6v b6v c6v d6v e6v f6v g6v h6v

    a5h b5h c5h d5h e5h f5h g5h h5h
    a5v b5v c5v d5v e5v f5v g5v h5v

    a4h b4h c4h d4h e4h f4h g4h h4h
    a4v b4v c4v d4v e4v f4v g4v h4v

    a3h b3h c3h d3h e3h f3h g3h h3h
    a3v b3v c3v d3v e3v f3v g3v h3v

    a2h b2h c2h d2h e2h f2h g2h h2h
    a2v b2v c2v d2v e2v f2v g2v h2v
  ) }

  context 'empty board' do
    it 'allows all possible fences' do
      expect(rules.possible_fence_placements(board)).to contain_exactly(*all_possible_fences)
    end
  end

  context 'some fences' do
    before(:each) do
      board.add_fence('e5h')
      board.add_fence('d2v')
    end

    it 'does not allow overlapping' do
      expected = all_possible_fences - %w(d5h e5h f5h e5v d3v d2v d2h)
      expect(rules.possible_fence_placements(board)).to contain_exactly(*expected)
    end
  end

  context 'no fences and two pawns' do
    before(:each) do
      board.add_pawn('e4')
      board.add_pawn('b2')
    end

    it 'allows all possible fences' do
      expect(rules.possible_fence_placements(board)).to contain_exactly(*all_possible_fences)
    end
  end

  context 'some fences and pawns not on goal rows' do
    before(:each) do
      board.add_fence('a3h')
      board.add_fence('h3h')
      board.add_pawn('h2')
      board.add_pawn('b2')
    end

    it 'does not allow cutting off paths to goals' do
      expected = all_possible_fences - %w(a3h b3h a3v h3h g3h h3v) # overlapping
      expected = expected - %w(b2v) # goal cut off
      expect(rules.possible_fence_placements(board)).to contain_exactly(*expected)
    end
  end
end
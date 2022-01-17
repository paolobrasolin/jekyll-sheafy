require "jekyll/sheafy/directed_graph"

describe Jekyll::Sheafy::DirectedGraph do
  describe "#ensure_valid!" do
    it "rejects adjacency list w/ missing keys" do
      graph = Jekyll::Sheafy::DirectedGraph[{ 1 => [2], 2 => [3], 4 => [5, 3] }]
      expect { graph.ensure_valid! }.to raise_error do |error|
        expect(error).to be_a(Jekyll::Sheafy::DirectedGraph::MissingKeysError)
        expect(error.payload).to eq([3, 5])
      end
    end

    it "rejects adjacency list w/ invalid values" do
      graph = Jekyll::Sheafy::DirectedGraph[{ 1 => [], 2 => nil, 3 => "foo" }]
      expect { graph.ensure_valid! }.to raise_error do |error|
        expect(error).to be_a(Jekyll::Sheafy::DirectedGraph::InvalidValuesError)
        expect(error.payload).to eq([nil, "foo"])
      end
    end
  end

  describe "#ensure_simple!" do
    it "rejects graph w/ multiple edges" do
      graph = Jekyll::Sheafy::DirectedGraph[
        { 1 => [2], 2 => [3, 4, 3], 3 => [], 4 => [5, 5, 5], 5 => [] }]
      expect { graph.ensure_simple! }.to raise_error do |error|
        expect(error).to be_a(Jekyll::Sheafy::DirectedGraph::MultipleEdgesError)
        expect(error.payload).to eq({ 2 => [3], 4 => [5] })
      end
    end

    it "rejects graph w/ loops" do
      graph = Jekyll::Sheafy::DirectedGraph[{ 1 => [1, 2], 2 => [3], 3 => [3] }]
      expect { graph.ensure_simple! }.to raise_error do |error|
        expect(error).to be_a(Jekyll::Sheafy::DirectedGraph::LoopsError)
        expect(error.payload).to eq({ 1 => [1], 3 => [3] })
      end
    end
  end

  describe "#ensure_acyclic!" do
    it "rejects graph w/ cycles" do
      graph = Jekyll::Sheafy::DirectedGraph[
        { 1 => [2], 2 => [3], 3 => [1], 4 => [5], 5 => [4], 6 => [7], 7 => [] }]
      expect { graph.ensure_acyclic! }.to raise_error do |error|
        expect(error).to be_a(Jekyll::Sheafy::DirectedGraph::CyclesError)
        expect(error.payload).to eq([[1, 2, 3], [4, 5]])
      end
    end
  end

  describe "#ensure_transposed_pseudoforest!" do
    it "rejects graph w/ indegrees > 1" do
      graph = Jekyll::Sheafy::DirectedGraph[
        { 1 => [2, 3], 2 => [4], 3 => [4, 5], 4 => [], 5 => [] }]
      expect { graph.ensure_transposed_pseudoforest! }.to raise_error do |error|
        expect(error).to be_a(Jekyll::Sheafy::DirectedGraph::IndegreeError)
        expect(error.payload).to eq({ 2 => [4], 3 => [4] })
      end
    end
  end

  describe "#ensure_rooted_forest!" do
    it "accepts an empty graph" do
      graph = Jekyll::Sheafy::DirectedGraph[{}]
      expect { graph.ensure_rooted_forest! }.to_not raise_error
    end

    it "accepts a single node" do
      graph = Jekyll::Sheafy::DirectedGraph[{ 1 => [] }]
      expect { graph.ensure_rooted_forest! }.to_not raise_error
    end

    it "accepts a rooted tree" do
      graph = Jekyll::Sheafy::DirectedGraph[
        { 1 => [2, 3], 2 => [], 3 => [4], 4 => [] }]
      expect { graph.ensure_rooted_forest! }.to_not raise_error
    end

    it "accepts a rooted forest" do
      graph = Jekyll::Sheafy::DirectedGraph[
        { 1 => [2, 3], 2 => [], 3 => [4], 4 => [],
          a: [:b, :e], b: [:c, :d], c: [], d: [], e: [] }]
      expect { graph.ensure_rooted_forest! }.to_not raise_error
    end
  end
end

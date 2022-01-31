require "jekyll/sheafy/dependencies"

describe Jekyll::Sheafy::Dependencies do
  describe ".scan_includes" do
    it "detects nothing on empty file" do
      node = Node.new(content: "")
      expect(subject.scan_includes(node)).to eq([])
    end

    it "detects includes mixed with text" do
      node = Node.new(content: <<~CONTENT)
        Lorem ipsum.
        @include{0001}
        Dolor sit amet.
        @include{0002}
        Yadda yadda yadda.
        @include{0003}
      CONTENT
      expect(subject.scan_includes(node)).to eq(["0001", "0002", "0003"])
    end

    it "keeps duplicates" do
      node = Node.new(content: <<~CONTENT)
        @include{0001}
        @include{0001}
      CONTENT
      expect(subject.scan_includes(node)).to eq(["0001", "0001"])
    end
  end

  describe ".build_adjacency_list" do
    it "builds nothing on empty index" do
      index = {}
      expect(subject.build_adjacency_list(index)).to eq({})
    end

    it "correctly interpretes a boring index" do
      index = {
        "0000" => Node.new(content: "@include{0001}\n@include{0002}\n"),
        "0001" => Node.new(content: ""),
        "0002" => Node.new(content: "@include{0003}\n@include{0004}\n"),
        "0003" => Node.new(content: ""),
        "0004" => Node.new(content: ""),
      }
      expect(subject.build_adjacency_list(index)).to eq({
        "0000" => ["0001", "0002"],
        "0001" => [],
        "0002" => ["0003", "0004"],
        "0003" => [],
        "0004" => [],
      })
    end

    it "keeps duplicates" do
      index = {
        "0000" => Node.new(content: "@include{0001}\n" * 2),
        "0001" => Node.new(content: ""),
      }
      expect(subject.build_adjacency_list(index)).to eq(
        { "0000" => ["0001", "0001"], "0001" => [] }
      )
    end
  end

  describe ".attribute_neighbors!" do
    let(:parent) { Node.new(data: {}) }
    let(:child_foo) { Node.new(data: {}) }
    let(:child_bar) { Node.new(data: {}) }
    let(:child_qux) { Node.new(data: {}) }
    let(:graph) { { parent => [child_foo, child_bar, child_qux] } }

    it "adds parent to all children" do
      expect { subject.attribute_neighbors!(graph) }.to \
        change { child_foo.data["parent"] }.to(parent).and \
          change { child_bar.data["parent"] }.to(parent).and \
            change { child_qux.data["parent"] }.to(parent)
    end

    it "adds all children to parent" do
      expect { subject.attribute_neighbors!(graph) }.to \
        change { parent.data["children"] }.to([child_foo, child_bar, child_qux])
    end

    it "adds older siblings to all children" do
      expect { subject.attribute_neighbors!(graph) }.to \
        change { child_foo.data["predecessors"] }.to([]).and \
          change { child_bar.data["predecessors"] }.to([child_foo]).and \
            change { child_qux.data["predecessors"] }.to([child_foo, child_bar])
    end

    it "adds younger siblings to all children" do
      expect { subject.attribute_neighbors!(graph) }.to \
        change { child_foo.data["successors"] }.to([child_bar, child_qux]).and \
          change { child_bar.data["successors"] }.to([child_qux]).and \
            change { child_qux.data["successors"] }.to([])
    end
  end

  describe ".attribute_ancestors!" do
    it "adds empty ancestry to node w/o parent" do
      root = Node.new(data: {})
      expect { subject.attribute_ancestors!(root) }.to \
        change { root.data["ancestors"] }.to([])
    end

    it "builds ancestry inductively on node w/ parent" do
      parent = Node.new(data: { "ancestors" => [:foo, :bar] })
      child = Node.new(data: { "parent" => parent })
      expect { subject.attribute_ancestors!(child) }.to \
        change { child.data["ancestors"] }.to([:foo, :bar, parent])
    end
  end
end

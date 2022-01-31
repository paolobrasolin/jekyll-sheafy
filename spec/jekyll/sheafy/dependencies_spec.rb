require "jekyll/sheafy/dependencies"

describe Jekyll::Sheafy::Dependencies do
  let(:site) { Site.new(config: {}) }

  describe ".validate_config!" do
    it "accepts blank configuration" do
      config = { "sheafy" => {} }
      expect { subject.validate_config!(config) }.to_not raise_error
    end

    it "rejects inheritables key which is not an array" do
      config = { "sheafy" => { "inheritable" => 42 } }
      expect { subject.validate_config!(config) }.
        to raise_error(Jekyll::Sheafy::Dependencies::InvalidConfig)
    end

    it "rejects inheritables which are not strings" do
      config = { "sheafy" => { "inheritable" => [:foo] } }
      expect { subject.validate_config!(config) }.
        to raise_error(Jekyll::Sheafy::Dependencies::InvalidConfig)
    end

    it "accepts inheritables which are strings" do
      config = { "sheafy" => { "inheritable" => ["foo"] } }
      expect { subject.validate_config!(config) }.to_not raise_error
    end
  end

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

    it "adds itself as root to node w/o parent" do
      root = Node.new(data: {})
      expect { subject.attribute_ancestors!(root) }.to \
        change { root.data["root"] }.to(root)
    end

    it "gets root from parent if present" do
      parent = Node.new(data: { "root" => :root })
      child = Node.new(data: { "parent" => parent })
      expect { subject.attribute_ancestors!(child) }.to \
        change { child.data["root"] }.to(:root)
    end
  end

  describe ".attribute_depth!" do
    it "adds depth zero to node w/o w/o parent" do
      root = Node.new(data: {})
      expect { subject.attribute_depth!(root) }.to \
        change { root.data["depth"] }.to(0)
    end

    it "increases depth from parent if present" do
      parent = Node.new(data: { "depth" => 41 })
      child = Node.new(data: { "parent" => parent })
      expect { subject.attribute_depth!(child) }.to \
        change { child.data["depth"] }.to(42)
    end
  end

  describe ".attribute_clicks!" do
    it "adds unlabeled click to node without clicker" do
      node = Node.new(data: {})
      expect { subject.attribute_clicks!(node) }.to \
        change { node.data["clicks"] }.to([{ "clicker" => nil, "value" => 0 }])
    end

    it "adds labeled click to node with clicker" do
      node = Node.new(data: { "clicker" => "FOO" })
      expect { subject.attribute_clicks!(node) }.to \
        change { node.data["clicks"] }.to([{ "clicker" => "FOO", "value" => 0 }])
    end

    it "prepends parent's clicks to child" do
      parent = Node.new(data: {})
      child = Node.new(data: {})
      parent.data["children"] = [child]
      expect { subject.attribute_clicks!(parent) }.to \
        change { child.data["clicks"] }.to([
          { "clicker" => nil, "value" => 0 },
          { "clicker" => nil, "value" => 0 },
        ])
    end

    it "adds consecutive clicks to homogeneous children" do
      parent = Node.new(data: {})
      child_foo = Node.new(data: {})
      child_bar = Node.new(data: {})
      child_qux = Node.new(data: {})
      parent.data["children"] = [child_foo, child_bar, child_qux]

      expect { subject.attribute_clicks!(parent) }.to \
        change { child_foo.data["clicks"] }.to([
          { "clicker" => nil, "value" => 0 },
          { "clicker" => nil, "value" => 0 },
        ]).and \
          change { child_bar.data["clicks"] }.to([
            { "clicker" => nil, "value" => 0 },
            { "clicker" => nil, "value" => 1 },
          ]).and \
            change { child_qux.data["clicks"] }.to([
              { "clicker" => nil, "value" => 0 },
              { "clicker" => nil, "value" => 2 },
            ])
    end

    it "adds grouped consecutive clicks to dishomogeneous children" do
      parent = Node.new(data: { "clicker" => "Z" })
      child_A0 = Node.new(data: { "clicker" => "A" })
      child_A1 = Node.new(data: { "clicker" => "A" })
      child_B0 = Node.new(data: { "clicker" => "B" })
      child_A2 = Node.new(data: { "clicker" => "A" })
      child_B1 = Node.new(data: { "clicker" => "B" })
      parent.data["children"] =
        [child_A0, child_A1, child_B0, child_A2, child_B1]

      expect { subject.attribute_clicks!(parent) }.to \
        change { child_A0.data["clicks"] }.to([
          { "clicker" => "Z", "value" => 0 },
          { "clicker" => "A", "value" => 0 },
        ]).and \
          change { child_A1.data["clicks"] }.to([
            { "clicker" => "Z", "value" => 0 },
            { "clicker" => "A", "value" => 1 },
          ]).and \
            change { child_B0.data["clicks"] }.to([
              { "clicker" => "Z", "value" => 0 },
              { "clicker" => "B", "value" => 0 },
            ]).and \
              change { child_A2.data["clicks"] }.to([
                { "clicker" => "Z", "value" => 0 },
                { "clicker" => "A", "value" => 2 },
              ]).and \
                change { child_B1.data["clicks"] }.to([
                  { "clicker" => "Z", "value" => 0 },
                  { "clicker" => "B", "value" => 1 },
                ])
    end
  end

  describe ".attribute_inheritable!" do
    let(:site) { Site.new(config: { "sheafy" => { "inheritable" => ["foo"] } }) }

    it "inherits inhertiable attributes" do
      parent = Node.new(site: site, data: { "parent" => nil, "foo" => "bar" })
      child = Node.new(site: site, data: { "parent" => parent })

      expect { subject.attribute_inheritable!(child) }.
        to change { child.data["foo"] }.to ("bar")
    end

    it "ignores non inheritable attributes" do
      parent = Node.new(site: site, data: { "parent" => nil, "XXX" => "bar" })
      child = Node.new(site: site, data: { "parent" => parent })

      expect { subject.attribute_inheritable!(child) }.
        not_to change { child.data["XXX"] }
    end

    it "abides to overrides" do
      parent = Node.new(site: site, data: { "parent" => nil, "foo" => "bar" })
      child = Node.new(site: site, data: { "parent" => parent, "foo" => "qux" })

      expect { subject.attribute_inheritable!(child) }.
        not_to change { child.data["foo"] }
    end
  end
end

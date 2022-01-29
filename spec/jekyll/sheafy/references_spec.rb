require "jekyll/sheafy/references"

describe Jekyll::Sheafy::References do
  describe ".scan_references" do
    it "detects nothing on empty file" do
      node = Node.new(content: "")
      expect(subject.scan_references(node)).to eq([])
    end

    it "detects includes mixed with text" do
      node = Node.new(content: <<~CONTENT)
        Lorem ipsum.
        {% ref 0001 %}
        Dolor sit amet.
        {% ref 0002 %}
        Yadda yadda yadda.
        {% ref 0003 %}
      CONTENT
      expect(subject.scan_references(node)).to eq(["0001", "0002", "0003"])
    end

    it "detects pref and cref" do
      node = Node.new(content: <<~CONTENT)
        {% ref 0001 %}
        {% pref 0002 %}
        {% cref 0003 %}
      CONTENT
      expect(subject.scan_references(node)).to eq(["0001", "0002", "0003"])
    end

    it "keeps duplicates" do
      node = Node.new(content: <<~CONTENT)
        {% ref 0001 %}
        {% ref 0001 %}
      CONTENT
      expect(subject.scan_references(node)).to eq(["0001", "0001"])
    end
  end

  describe ".build_adjacency_list" do
    it "builds nothing on empty index" do
      index = {}
      expect(subject.build_adjacency_list(index)).to eq({})
    end

    it "correctly interpretes a boring index" do
      index = {
        "0000" => Node.new(content: "{%ref 0001%}{%ref 0002%}{%ref 0001%}"),
        "0001" => Node.new(content: "{%ref 0000%}{%ref 0002%}"),
        "0002" => Node.new(content: ""),
      }
      expect(subject.build_adjacency_list(index)).to eq({
        "0000" => ["0001", "0002", "0001"],
        "0001" => ["0000", "0002"],
        "0002" => [],
      })
    end

    it "keeps duplicates" do
      index = {
        "0000" => Node.new(content: "{% ref 0001 %}\n" * 2),
        "0001" => Node.new(content: ""),
      }
      expect(subject.build_adjacency_list(index)).to eq(
        { "0000" => ["0001", "0001"], "0001" => [] }
      )
    end
  end
end

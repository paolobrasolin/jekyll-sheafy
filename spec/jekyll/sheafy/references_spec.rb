require "jekyll/sheafy/references"

describe Jekyll::Sheafy::References do
  # TODO: ugh; we should refactor this into a stateless design.
  before { subject.load_config({}) }

  describe ".load_config" do
    it "rejects matchers w/o 'slug' named group" do
      config = { "references" => { "matchers" => [/foobar/] } }
      expect { subject.load_config(config) }.
        to raise_error(Jekyll::Sheafy::References::InvalidMatcher)
    end

    it "accepts matchers w/ 'slug' named group" do
      config = { "references" => { "matchers" => [/foo(?<slug>.+?)bar/] } }
      expect { subject.load_config(config) }.to_not raise_error
    end
  end

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

    it "allows for customization" do
      subject.load_config({ "references" => {
        "matchers" => [
          /{%\s*[pc]?ref (?<slug>.+?)\s*%}/,
          /{%\s*cite (?<slug>.+?)\s*%}/,
        ],
      } })
      node = Node.new(content: <<~CONTENT)
        {% ref 0001 %}
        {% pref 0002 %}
        {% cref 0003 %}
        {% cite 0004 %}
      CONTENT
      expect(subject.scan_references(node)).
        to eq(["0001", "0002", "0003", "0004"])
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

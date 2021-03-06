require "jekyll/sheafy/references"

describe Jekyll::Sheafy::References do
  let(:site) { Site.new(config: {}) }

  describe ".validate_config!" do
    it "rejects matchers w/o 'slug' named group" do
      config = { "sheafy" => { "references" => {
        "matchers" => [/foobar/],
      } } }
      expect { subject.validate_config!(config) }.
        to raise_error(Jekyll::Sheafy::References::InvalidMatcher)
    end

    it "accepts matchers w/ 'slug' named group" do
      config = { "sheafy" => { "references" => {
        "matchers" => [/foo(?<slug>.+?)bar/],
      } } }
      expect { subject.validate_config!(config) }.to_not raise_error
    end
  end

  describe ".scan_references" do
    it "detects nothing on empty file" do
      node = Node.new(site: site, content: "")
      expect(subject.scan_references(node)).to eq([])
    end

    it "detects includes mixed with text" do
      node = Node.new(site: site, content: <<~CONTENT)
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
      site.config = { "sheafy" => { "references" => {
        "matchers" => [
          /{%\s*[pc]?ref (?<slug>.+?)\s*%}/,
          /{%\s*cite (?<foobar>.+?) (?<slug>.+?)\s*%}/,
        ],
      } } }
      node = Node.new(site: site, content: <<~CONTENT)
        {% ref 0001 %}
        {% pref 0002 %}
        {% cref 0003 %}
        {% cite hwat 0004 %}
      CONTENT
      expect(subject.scan_references(node)).
        to eq(["0001", "0002", "0003", "0004"])
    end

    it "keeps duplicates" do
      node = Node.new(site: site, content: <<~CONTENT)
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
        "0000" => Node.new(site: site, content: "{%ref 0001%}{%ref 0002%}{%ref 0001%}"),
        "0001" => Node.new(site: site, content: "{%ref 0000%}{%ref 0002%}"),
        "0002" => Node.new(site: site, content: ""),
      }
      expect(subject.build_adjacency_list(index)).to eq({
        "0000" => ["0001", "0002", "0001"],
        "0001" => ["0000", "0002"],
        "0002" => [],
      })
    end

    it "keeps duplicates" do
      index = {
        "0000" => Node.new(site: site, content: "{% ref 0001 %}\n" * 2),
        "0001" => Node.new(site: site, content: ""),
      }
      expect(subject.build_adjacency_list(index)).to eq(
        { "0000" => ["0001", "0001"], "0001" => [] }
      )
    end
  end

  describe ".attribute_neighbors!" do
    let(:referrer_a) { Node.new(data: {}) }
    let(:referrer_b) { Node.new(data: {}) }
    let(:referent_x) { Node.new(data: {}) }
    let(:referent_y) { Node.new(data: {}) }

    it "adds no referrers to referent w/o references" do
      graph = { referent_x => [] }
      expect { subject.attribute_neighbors!(graph) }.to \
        change { referent_x.data["referrers"] }.to([])
    end

    it "adds single referrer to single referent" do
      graph = { referrer_a => [referent_x], referent_x => [] }
      expect { subject.attribute_neighbors!(graph) }.to \
        change { referent_x.data["referrers"] }.to([referrer_a])
    end

    it "adds single referrer to multiple referents" do
      graph = { referrer_a => [referent_x, referent_y], referent_x => [], referent_y => [] }
      expect { subject.attribute_neighbors!(graph) }.to \
        change { referent_x.data["referrers"] }.to([referrer_a]).and \
          change { referent_y.data["referrers"] }.to([referrer_a])
    end

    it "does not duplicate referrers" do
      graph = { referrer_a => [referent_x, referent_x], referent_x => [] }
      expect { subject.attribute_neighbors!(graph) }.to \
        change { referent_x.data["referrers"] }.to([referrer_a])
    end

    it "adds no referents to referrer w/o references" do
      graph = { referrer_a => [] }
      expect { subject.attribute_neighbors!(graph) }.to \
        change { referrer_a.data["referents"] }.to([])
    end

    it "adds single referent to single referrer" do
      graph = { referrer_a => [referent_x], referent_x => [] }
      expect { subject.attribute_neighbors!(graph) }.to \
        change { referrer_a.data["referents"] }.to([referent_x])
    end

    it "adds multiple referents to single referrer" do
      graph = { referrer_a => [referent_x, referent_y], referent_x => [], referent_y => [] }
      expect { subject.attribute_neighbors!(graph) }.to \
        change { referrer_a.data["referents"] }.to([referent_x, referent_y])
    end

    it "does not duplicate referents" do
      graph = { referrer_a => [referent_x, referent_x], referent_x => [] }
      expect { subject.attribute_neighbors!(graph) }.to \
        change { referrer_a.data["referents"] }.to([referent_x])
    end
  end
end

require "jekyll/sheafy/taxa"

describe Jekyll::Sheafy::Taxa do
  let(:site) { Site.new(config: {}) }

  describe ".apply_taxon!" do
    it "does not explode if there's no config" do
      node = Node.new(site: site, data: {})
      expect { subject.apply_taxon!(node) }.
        not_to raise_error
    end

    it "does nothin to node w/o taxon" do
      site.config = { "sheafy" => { "taxa" => {
        "taxon_foo" => { "key" => "foo" },
      } } }
      node = Node.new(site: site, data: { "key" => "bar" })
      expect { subject.apply_taxon!(node) }.
        not_to change { node.data }
    end

    it "does nothin to node w/ undefined taxon" do
      site.config = { "sheafy" => { "taxa" => {
        "taxon_foo" => { "key" => "foo" },
      } } }
      node = Node.new(site: site, data: { "taxon" => "taxon_bar" })
      expect { subject.apply_taxon!(node) }.
        not_to change { node.data }
    end

    it "adds missing key" do
      site.config = { "sheafy" => { "taxa" => {
        "taxon_foo" => { "key" => "foo" },
      } } }
      node = Node.new(site: site, data: { "taxon" => "taxon_foo" })
      expect { subject.apply_taxon!(node) }.to change { node.data }.to(
        { "taxon" => "taxon_foo", "key" => "foo" }
      )
    end

    it "keeps existing key" do
      site.config = { "sheafy" => { "taxa" => {
        "taxon_foo" => { "key" => "foo" },
      } } }
      node = Node.new(site: site, data: {
                        "taxon" => "taxon_foo", "key" => "bar",
                      })
      expect { subject.apply_taxon!(node) }.
        not_to change { node.data }
    end
  end
end

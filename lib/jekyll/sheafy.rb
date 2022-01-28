require "jekyll"
require "jekyll/sheafy/dependencies"
require "jekyll/sheafy/references"
require "jekyll/sheafy/taxa"
require "jekyll/sheafy/version"

module Jekyll
  module Sheafy
    def self.process(site)
      nodes_index = build_nodes_index(site)
      Jekyll::Sheafy::Taxa.process(nodes_index)
      Jekyll::Sheafy::References.process(nodes_index)
      Jekyll::Sheafy::Dependencies.process(nodes_index)
    end

    def self.build_nodes_index(site)
      site.collections.values.flat_map(&:docs).
        filter { |doc| doc.data.key?(Jekyll::Sheafy::Taxa::TAXON_KEY) }.
        map { |doc| [doc.data["slug"], doc] }.to_h
    end
  end
end

Jekyll::Hooks.register :site, :post_read, priority: 30 do |site|
  Jekyll::Sheafy.process(site)
end

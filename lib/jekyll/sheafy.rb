require "jekyll/sheafy/version"
require "jekyll/sheafy/directed_graph"
require "jekyll/sheafy/dependencies"
require "jekyll/sheafy/references"
require "jekyll/sheafy/taxa"
require "jekyll"

module Jekyll
  module Sheafy
    def self.process(site)
      nodes = gather_node(site)
      Jekyll::Sheafy::Taxa.process(nodes)
      Jekyll::Sheafy::References.process(nodes)
      Jekyll::Sheafy::Dependencies.process_dependencies(nodes)
    end

    def self.gather_node(site)
      site.collections.values.flat_map(&:docs).
        filter { |doc| doc.data.key?(Jekyll::Sheafy::Taxa::TAXON_KEY) }.
        map { |doc| [doc.data["slug"], doc] }.to_h
    end

    # TODO: handle regenerator dependencies
    # if page&.key?('path')
    #   path = site.in_source_dir(source['path'])
    #   dependency = site.in_source_dir(targets.path)
    #   site.regenerator.add_dependency(path, dependency)
    # end
  end
end

Jekyll::Hooks.register :site, :post_read, priority: 30 do |site|
  Jekyll::Sheafy.process(site)
end

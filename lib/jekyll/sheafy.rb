require "jekyll/sheafy/version"
require "jekyll/sheafy/directed_graph"
require "jekyll/sheafy/dependencies"
require "jekyll/sheafy/taxa"
require "jekyll"

module Jekyll
  module Sheafy
    RE_REF_TAG = /{%\s*ref (?<slug>.+?)\s*%}/

    def self.process_references(nodes)
      # The structure of references is a directed graph,
      # where source = referrer and target = referent.

      nodes.values.each do |source|
        source.content.scan(RE_REF_TAG).each do |(slug)|
          target = nodes[slug]
          # TODO: handle missing targets
          target.data["referrers"] ||= []
          target.data["referrers"] << source
        end
      end

      # TODO: use a Set to avoid second pass
      nodes.values.each do |resource|
        resource.data["referrers"]&.uniq!
        resource.data["referrers"] ||= []
      end
    end

    def self.process(site)
      nodes = gather_node(site)
      Jekyll::Sheafy::Taxa.process(nodes)
      process_references(nodes)
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

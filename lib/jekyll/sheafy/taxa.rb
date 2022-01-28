module Jekyll
  module Sheafy
    module Taxa
      TAXON_KEY = "taxon"

      def self.process(nodes)
        nodes.values.each(&method(:apply_taxon!))
      end

      def self.apply_taxon!(node)
        taxon_name = node.data[TAXON_KEY]
        taxon_data = node.site.config.dig("sheafy", "taxa", taxon_name) || {}
        # TODO: handle missing taxa
        node.data.merge!(taxon_data) { |key, left, right| left }
      end
    end
  end
end

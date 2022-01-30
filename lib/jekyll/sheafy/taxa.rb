module Jekyll
  module Sheafy
    module Taxa
      TAXA_PATH = ["sheafy", "taxa"]
      TAXON_KEY = "taxon"

      def self.process(nodes_index)
        nodes_index.values.each(&method(:apply_taxon!))
      end

      #==[ Data generation ]====================================================

      def self.apply_taxon!(node)
        taxon_name = node.data[TAXON_KEY]
        taxon_data = node.site.config.dig(*TAXA_PATH, taxon_name) || {}
        # TODO: emit warning on undefined taxon
        node.data.merge!(taxon_data) { |key, left, right| left }
      end
    end
  end
end

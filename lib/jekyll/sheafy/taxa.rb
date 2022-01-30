module Jekyll
  module Sheafy
    module Taxa
      class Error < StandardError; end
      class InvalidTaxon < Error; end

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

      #==[ Config validation ]==================================================

      def self.validate_config!(config)
        config.dig(*TAXA_PATH)&.each(&method(:validate_taxon!))
      end

      def self.validate_taxon!(taxon_key, taxon_value)
        raise InvalidTaxon.new(<<~ERROR) unless taxon_value.is_a?(Hash)
          Sheafy configuration error: the value of taxon #{taxon_key} must be a hash.
        ERROR
      end
    end
  end
end

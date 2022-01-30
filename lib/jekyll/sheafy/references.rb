require "safe_yaml"
# NOTE: allows for rexexp entries in mathers array in config
SafeYAML::OPTIONS[:whitelisted_tags].push("!ruby/regexp")

module Jekyll
  module Sheafy
    module References
      class Error < StandardError; end
      class InvalidMatcher < Error; end

      MATCHERS_PATH = ["sheafy", "references", "matchers"]
      DEFAULT_MATCHERS = [
        /{%\s*ref (?<slug>.+?)\s*%}/,
      ]
      SLUG_CAPTURE_NAME = "slug"
      REFERRERS_KEY = "referrers"

      def self.process(nodes_index)
        adjacency_list = build_adjacency_list(nodes_index)
        denormalize_adjacency_list!(adjacency_list, nodes_index)
        # NOTE: topology is arbitrary so no single pass technique is possible.
        nodes_index.values.each { |node| node.data[REFERRERS_KEY] = [] }
        attribute_neighbors!(adjacency_list)
      end

      #==[ Graph building ]=====================================================

      def self.scan_references(node)
        matchers = node.site.config.dig(*MATCHERS_PATH) || DEFAULT_MATCHERS
        matchers.flat_map do |matcher|
          index = matcher.named_captures.fetch(SLUG_CAPTURE_NAME).fetch(0).pred
          node.content.scan(matcher).map { |captures| captures.fetch(index) }
        end
      end

      def self.build_adjacency_list(nodes_index)
        nodes_index.transform_values(&method(:scan_references))
      end

      def self.denormalize_adjacency_list!(list, index)
        # TODO: handle missing nodes
        list.transform_keys!(&index)
        list.values.each { |children| children.map!(&index) }
      end

      #==[ Data generation ]====================================================

      def self.attribute_neighbors!(list)
        list.each do |referrer, referents|
          # TODO: can referents be useful?
          # referrer.data["referents"] = referents.uniq
          referents.each do |referent|
            next if referent.data[REFERRERS_KEY].include?(referrer)
            referent.data[REFERRERS_KEY] << referrer
          end
        end
      end

      #==[ Config validation ]==================================================

      def self.validate_config!(config)
        config.dig(*MATCHERS_PATH)&.each(&method(:validate_matcher!))
      end

      def self.validate_matcher!(matcher)
        valid = matcher.named_captures.key?(SLUG_CAPTURE_NAME)
        valid &&= matcher.named_captures.fetch(SLUG_CAPTURE_NAME).one?
        raise InvalidMatcher.new(<<~ERROR) unless valid
          Sheafy configuration error: the matcher #{matcher} must have ONE capturing group named "#{SLUG_CAPTURE_NAME}".
        ERROR
      end
    end
  end
end

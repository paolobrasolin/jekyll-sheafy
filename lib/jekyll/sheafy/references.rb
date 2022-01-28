module Jekyll
  module Sheafy
    module References
      RE_REF_TAG = /{%\s*ref (?<slug>.+?)\s*%}/
      REFERRERS_KEY = "referrers"

      def self.process(nodes_index)
        adjacency_list = build_adjacency_list(nodes_index)
        denormalize_adjacency_list!(adjacency_list, nodes_index)
        # NOTE: topology is arbitrary so no single pass technique is possible.
        nodes_index.values.each { |node| node.data[REFERRERS_KEY] = [] }
        attribute_neighbors!(adjacency_list)
      end

      def self.scan_references(node)
        node.content.scan(RE_REF_TAG).flatten
      end

      def self.build_adjacency_list(nodes_index)
        nodes_index.transform_values(&method(:scan_references))
      end

      def self.denormalize_adjacency_list!(list, index)
        # TODO: handle missing nodes
        list.transform_keys!(&index)
        list.values.each { |children| children.map!(&index) }
      end

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
    end
  end
end

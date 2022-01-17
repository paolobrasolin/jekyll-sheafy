require "tsort"

module Jekyll
  module Sheafy
    class DirectedGraph < Hash
      class PayloadError < StandardError
        attr_reader :payload

        def initialize(payload)
          @payload = payload
          super
        end
      end

      class MissingKeysError < PayloadError; end
      class InvalidValuesError < PayloadError; end
      class MultipleEdgesError < PayloadError; end
      class LoopsError < PayloadError; end
      class CyclesError < PayloadError; end
      class IndegreeError < PayloadError; end

      def ensure_rooted_forest!
        ensure_valid!
        ensure_simple!
        ensure_acyclic!
        ensure_transposed_pseudoforest!
      end

      def ensure_valid!
        invalid_values = values.reject { |v| v.is_a? Array }
        raise InvalidValuesError.new(invalid_values) if invalid_values.any?
        missing_keys = values.flat_map { |v| v - keys }.uniq
        raise MissingKeysError.new(missing_keys) if missing_keys.any?
      end

      def ensure_simple!
        multiple_edges =
          transform_values { |cs| cs.tally.filter { |_, v| v > 1 }.keys }.
            reject { |_, cs| cs.empty? }
        raise MultipleEdgesError.new(multiple_edges) if multiple_edges.any?
        loops = filter { |k, v| v.include?(k) }.keys.map { |k| [k, [k]] }.to_h
        raise LoopsError.new(loops) if loops.any?
      end

      def ensure_acyclic!
        cycles = TSort.strongly_connected_components(method(:tsort_each_node), method(:tsort_each_child)).reject(&:one?)
        raise CyclesError.new(cycles) if cycles.any?
      end

      def ensure_transposed_pseudoforest!
        # Note that
        #   "transposed graph is a pseudoforest"
        # = "transposed graph has outdegrees <= 1"
        # = "graph has indegrees <= 1"
        t_graph = self.class.transpose(self)
        t_edges_from_high_outdeg = t_graph.filter { |_, ns| ns.size > 1 }
        return if t_edges_from_high_outdeg.empty?
        edges_to_high_indeg = self.class.transpose(t_edges_from_high_outdeg)
        raise IndegreeError.new(edges_to_high_indeg)
      end

      def topologically_sorted
        # TODO: cache tsort calculation
        ensure_acyclic!
        TSort.tsort(method(:tsort_each_node), method(:tsort_each_child))
      end

      def self.transpose(adjacency_list)
        Hash.new { |h, k| h[k] = [] }.tap do |transposed_adjacency_list|
          adjacency_list.each_pair do |parent, children|
            children.each { |child| transposed_adjacency_list[child] << parent }
          end
        end
      end

      private

      def tsort_each_node(&block)
        each_key(&block)
      end

      def tsort_each_child(node, &block)
        fetch(node).each(&block)
      end
    end
  end
end

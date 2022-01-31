require "jekyll/sheafy/directed_graph"

module Jekyll
  module Sheafy
    module Dependencies
      RE_INCLUDE_TAG = /^@include{(?<slug>.+?)}$/

      def self.process(nodes)
        adjacency_list = build_adjacency_list(nodes)
        graph = build_rooted_forest!(adjacency_list)
        denormalize_adjacency_list!(graph, nodes)
        attribute_neighbors!(graph)

        # NOTE: top.ord. is good to denormalize from leaves up to roots, while
        # rev.top.ord is good to denormalize data from roots down to leaves.
        # I.e.: for destructive procedures which need the altered children use
        #   tsorted_nodes.each { |node| ... }
        # and for destructive procedures which need the original children use
        #   tsorted_nodes.reverse.each { |node| ... }
        tsorted_nodes = graph.topologically_sorted

        tsorted_nodes.reverse.each do |node|
          attribute_ancestors!(node)
          attribute_depth!(node)
          attribute_clicks!(node)
          attribute_inheritable!(node)
        end

        # NOTE: this pass is separate to have data available in layouts.
        tsorted_nodes.reverse.each do |node|
          flatten_subtree!(node, nodes)
        end
      end

      #==[ Graph building ]=====================================================

      def self.scan_includes(node)
        node.content.scan(RE_INCLUDE_TAG).flatten
      end

      def self.build_adjacency_list(nodes_index)
        nodes_index.transform_values(&method(:scan_includes))
      end

      def self.build_rooted_forest!(adjacency_list)
        Sheafy::DirectedGraph[adjacency_list].
          tap(&:ensure_rooted_forest!)
      rescue Jekyll::Sheafy::DirectedGraph::Error => error
        raise StandardError.new(<<~MESSAGE)
                Sheafy processing error! The nodes dependency graph MUST be a directed rooted forest. #{error.message}
              MESSAGE
      end

      def self.denormalize_adjacency_list!(list, index)
        # TODO: handle missing nodes
        list.transform_keys!(&index)
        list.values.each { |children| children.map!(&index) }
      end

      #==[ Data generation ]====================================================

      def self.attribute_neighbors!(list)
        list.each do |parent, children|
          parent.data["children"] = children
          children.each_with_index do |child, index|
            child.data["parent"] ||= parent
            child.data["predecessors"] = children.take(index)
            child.data["successors"] = children.drop(index.succ)
          end
        end
      end

      def self.attribute_ancestors!(node)
        node.data["ancestors"] = []
        parent = node.data["parent"]
        if parent
          ancestors = [*parent.data["ancestors"], parent]
          node.data["ancestors"] = ancestors
        end
        node.data["root"] = parent&.data&.[]("root") || node
      end

      def self.attribute_depth!(node)
        parent = node.data["parent"]
        node.data["depth"] = 1 + (parent&.data&.[]("depth") || -1)
      end

      def self.attribute_clicks!(node)
        node.data["clicks"] ||= [
          { "clicker" => node.data["clicker"], "value" => 0 },
        ]
        node.data["children"]&.
          group_by { |child| child.data["clicker"] }&.
          each do |clicker, children|
          children.each_with_index do |child, index|
            clicks = node.data["clicks"].dup
            clicks << { "clicker" => clicker, "value" => index }
            child.data["clicks"] = clicks
          end
        end
      end

      INHERITABLE_PATH = ["sheafy", "inheritable"]

      def self.attribute_inheritable!(node)
        inheritable = node.site.config.dig(*INHERITABLE_PATH) || []
        return unless (parent = node.data["parent"])
        inherited = parent.data.slice(*inheritable)
        # TODO: how/when do we need to clone/dup here?
        node.data.merge!(**inherited) { |key, left, right| left }
      end

      #==[ Layout flattening ]==================================================

      SUBLAYOUT_KEY = "sublayout"
      SUBLAYOUT_DEFAULT_VALUE = "sheafy/node/default"
      SUBROOT_KEY = "subroot"

      def self.apply_sublayout(resource, content, subroot)
        sublayout = resource.data.fetch(SUBLAYOUT_KEY, SUBLAYOUT_DEFAULT_VALUE)
        # NOTE: all this mess is just to adhere to Jekyll's internals
        site = resource.site
        payload = site.site_payload
        payload["page"] = resource.to_liquid
        payload["page"].merge!(SUBROOT_KEY => subroot)
        payload["content"] = content
        info = {
          :registers => { :site => site, :page => payload["page"] },
          :strict_filters => site.config["liquid"]["strict_filters"],
          :strict_variables => site.config["liquid"]["strict_variables"],
        }
        layout = site.layouts[sublayout]
        # TODO add_regenerator_dependencies(layout)
        template = site.liquid_renderer.file(layout.path).parse(layout.content)
        # TODO: handle warnings like https://github.com/jekyll/jekyll/blob/0b12fd26aed1038f69169b665818f5245e4f4b6d/lib/jekyll/renderer.rb#L126
        template.render!(payload, info)
        # TODO: handle exceptions like https://github.com/jekyll/jekyll/blob/0b12fd26aed1038f69169b665818f5245e4f4b6d/lib/jekyll/renderer.rb#L131
      end

      def self.flatten_subtree!(node, nodes)
        node.content = flatten_subtree(node, nodes)
      end

      def self.flatten_subtree(resource, resources, subroot = resource)
        content = resource.content.gsub(RE_INCLUDE_TAG) do
          doc = resources[Regexp.last_match[:slug]]
          # TODO: handle missing references
          flatten_subtree(doc, resources, subroot)
        end
        apply_sublayout(resource, content, subroot)
      end
    end
  end
end

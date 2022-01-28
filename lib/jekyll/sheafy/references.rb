module Jekyll
  module Sheafy
    module References
      RE_REF_TAG = /{%\s*ref (?<slug>.+?)\s*%}/

      def self.process(nodes)
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
    end
  end
end

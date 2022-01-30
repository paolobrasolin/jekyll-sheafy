module Jekyll
  module Sheafy
    # NOTE: be careful in wielding magick!
    class TemplateError < StandardError
      attr_reader :payload

      def initialize(*payload)
        @payload = payload
      end

      def to_s
        self.class.instance_variable_get(:@template) % payload
      end

      def self.build(template)
        raise ArgumentError.new(<<~MESSAGE) unless template.is_a?(String)
          wrong type of argument (given #{template.class}, expected String)
        MESSAGE
        Class.new(self) do
          @template = template
        end
      end
    end
  end
end

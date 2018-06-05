require 'alces/support/field'
require 'json'

module Alces
  module Support
    class Issue
      attr_accessor :title, :identifier

      def initialize(metadata)
        self.title = metadata['title']
        self.identifier = metadata['identifier']
      end

      def fields
        @fields ||= load_fields
      end

      private
      def load_fields
        json = File.read(File.join(Config.root, 'etc', 'types', "#{identifier}.json"))
        JSON.parse(json).map(&Field.method(:new))
      end
    end
  end
end

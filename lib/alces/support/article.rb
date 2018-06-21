module Alces
  module Support
    class Article
      attr_accessor :title, :identifier, :content

      def initialize(metadata)
        self.title = metadata['title']
        self.identifier = metadata['identifier']
        self.content = metadata['content']
      end
    end
  end
end

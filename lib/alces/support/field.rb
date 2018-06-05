module Alces
  module Support
    class Field
      attr_accessor :name, :type, :help, :content

      def initialize(metadata)
        self.name = metadata['name']
        self.type = metadata['type']
        self.help = metadata['help']
        self.content = metadata['content']
      end
    end
  end
end

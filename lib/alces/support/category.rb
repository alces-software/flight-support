require 'alces/support/issue'
require 'yaml'

module Alces
  module Support
    class Category
      class << self
        def each(&block)
          all.each(&block)
        end

        def all
          @all ||=
            YAML.load_file(File.join(Config.root, 'etc', 'categories.yml'))
              .map(&Category.method(:new))
        end
      end

      attr_accessor :title, :issues

      def initialize(metadata)
        self.title = metadata['title']
        self.issues = metadata['issues'].map(&Issue.method(:new))
      end
    end
  end
end

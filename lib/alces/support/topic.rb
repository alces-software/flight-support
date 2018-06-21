require 'alces/support/article'
require 'yaml'

module Alces
  module Support
    class Topic
      class << self
        def each(&block)
          all.each(&block)
        end

        def all
          @all ||=
            YAML.load_file(File.join(Config.root, 'etc', 'topics.yml'))
              .map(&Topic.method(:new))
        end
      end

      attr_accessor :title, :articles, :subtopics

      def initialize(metadata)
        @title = metadata['title']
        if metadata['articles']
          @articles = metadata['articles'].map(&Article.method(:new))
        end
        if metadata['subtopics']
          @subtopics = metadata['subtopics'].map(&Topic.method(:new))
        end
      end

      def has_subtopics?
        !@subtopics.nil? && !@subtopics.empty?
      end

      def has_articles?
        !@articles.nil? && !@articles.empty?
      end
    end
  end
end
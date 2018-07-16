require 'alces/support/api'
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
          @all ||= API.new.fetch_topics.map(&Topic.method(:new))
        end
      end

      attr_accessor :title, :articles, :subtopics

      def initialize(attrs)
        @title = attrs['title']
        if attrs['articles']
          @articles = attrs['articles'].map(&Article.method(:new))
        end
        if attrs['subtopics']
          @subtopics = attrs['subtopics'].map(&Topic.method(:new))
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

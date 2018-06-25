require 'tty-command'

module Alces
  module Support
    class Article
      attr_accessor :title, :url, :meta

      def initialize(metadata)
        @title = metadata['title']
        @url = metadata['url']
        @meta = metadata['meta']
      end

      def content
        return @_content if defined? @_content
        @_content =
          begin
            result = cmd.run(<<-EOF, input: raw_content
              pandoc --from rst \
                --to man \
                --standalone \
                --metadata title='#{@title}' \
                --metadata section=#{@meta['section'].to_i} \
                --metadata author='#{@meta['author']}' \
                --metadata date='#{@meta['date']}'  \
                --output=-
                    EOF
                   )
            result.out
          end
      end

      def raw_content
        return @_raw_content if defined? @_raw_content
        @_raw_content =
          begin
            result = cmd.run('curl', @url)
            result.out
          end
      end

      def cmd
        @_cmd ||= TTY::Command.new(printer: :null)
      end
    end
  end
end

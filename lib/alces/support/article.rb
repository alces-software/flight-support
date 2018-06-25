require 'alces/support/errors'
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
            result = cmd.run!(<<-EOF, input: raw_content
              pandoc --from rst \
                --to man \
                --standalone \
                --metadata title='#{@title}' \
                #{content_metadata} \
                --output=-
                    EOF
                   )
            if result.failed?
              raise ArticleRenderError
            else
              result.out
            end
          end
      end

      def raw_content
        return @_raw_content if defined? @_raw_content
        @_raw_content =
          begin
            result = cmd.run('curl -w "%{http_code}\n"', @url)
            out = result.each.to_a
            status = out.last
            if status =~ /2\d\d/
              response_body = out[0..-2].join(TTY::Command.record_separator)
              response_body
            else
              raise ArticleNotFoundError
            end
          end
      end

      def cmd
        @_cmd ||= TTY::Command.new(printer: :null)
      end

      def content_metadata
        @meta.map do |k,v|
          "--metadata #{k}='#{v}'"
        end
          .join(" ")
      end
    end
  end
end

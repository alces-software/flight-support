require 'alces/pretty'
require 'alces/support/errors'
require 'alces/support/topic'
require 'colorize'
require 'tty-pager'
require 'tty-prompt'
require 'word_wrap'

module Alces
  module Support
    module Commands
      class Find
        def find(args, options)
          Pretty.banner('Alces Flight support request tool',
                        'v1.0.2 -- 2018-05-30')
          unless Config.auth_token
            prompt.warn WordWrap.ww(
              "Before you can use this tool you need to login to the Flight " \
              "Platform with:" 
            )
            prompt.warn "  #{Pretty.command('alces account login')}"
            puts ""
            prompt.warn WordWrap.ww(
              "If you do not yet have a Flight Platform account please sign up" \
              "for one with:"
            )
            prompt.warn "  #{Pretty.command('alces account subscribe')}"
            return
          end
          s2 = <<EOF
To find the right support article, please select from the following topics.
EOF
          puts Paint[s2, '#2794d8']
          topics = Topic.all
          if topics.empty?
            prompt.error "No topics are currently available."
          else
            main_loop(topics)
          end
        rescue NotAuthenticatedError
          prompt.error "Fetching topics failed"
          prompt.warn WordWrap.ww(
            "Before you can use this tool you need to login to the Flight " \
            "Platform with:" 
          )
          prompt.warn "  #{Pretty.command('alces account login')}"
        rescue TopicFetchError
          prompt.error $!.message
        rescue TTY::Prompt::Reader::InputInterrupt
          nil
        rescue HTTP::ConnectionError
          prompt.error WordWrap.ww(
            "Unable to connect to Flight Center. " \
            "Please check your network connection."
          )
        end

        def main_loop(topics)
          catch :quit do
            loop do
              catch :top do
                topic_drill_down(topics, top_level: true)
              end
            end
          end
        end

        def topic_drill_down(topics, top_level: false)
          prompt_title = top_level ? 'Topic:' : 'Subtopic'
          loop do
            topic = prompt.select(prompt_title) do |menu|
              topics.each do |t|
                menu.choice t.title, t
              end
              menu.choice "<< Back >>", ->() { throw :back } unless top_level
              menu.choice "<< Quit >>", ->() { throw :quit }
            end

            catch :back do
              if topic.has_subtopics?
                topic_drill_down(topic.subtopics)
              else
                select_article(topic)
              end
            end
          end
        end

        def select_article(topic)
          article = prompt.select('Article') do |menu|
            topic.articles.each do |a|
              menu.choice a.title, a
            end
            menu.choice "<< Back >>", ->() { throw :back }
            menu.choice "<< Quit >>", ->() { throw :quit }
          end

          display_article(article)
          ask_advice_found?
        rescue ArticleNotFoundError, ArticleRenderError, TTY::Command::ExitError
          puts Paint[error_message_for($!), :red]
          yes = prompt.yes?("Would you like to find another article?")
          if yes
            throw :top
          else
            throw :quit
          end
        end

        def display_article(article)
          pager.page(article.content)
        end

        def ask_advice_found?
          yes = prompt.yes?("Have you found the help you were looking for?")
          if yes
            throw :quit
          else
            throw :top
          end
        end

        def pager
          @pager ||= TTY::Pager.new(command: 'man -l -')
        end

        def prompt
          @prompt ||= TTY::Prompt.new(help_color: :cyan)
        end

        def error_message_for(ex)
          case ex
          when ArticleNotFoundError
            <<-EOF

    Unfortunately, the content for that article could not be found at the
    moment.
            EOF
          else
            <<-EOF

    Unfortunately, there was an unexpected error when trying to display the
    article.
            EOF
          end
        end
      end
    end
  end
end

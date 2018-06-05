require 'alces/pretty'
require 'alces/support/category'
require 'colorize'
require 'terminal-table'
require 'tty-prompt'
require 'mail'
require 'paint'

module Alces
  module Support
    module Commands
      class Request
        def request(args, options)
          Pretty.banner('Alces Flight support request tool',
                        'v1.0.2 -- 2018-05-30')
          if Config.email.nil? && options.from.nil?
            s2 = <<EOF
As you are not logged in to a Flight Platform account, you must
specify your email address.

Please supply the `--from` parameter.

EOF
            puts s2
          elsif SiteConfig.emailable?
            STDERR.puts options.from.inspect
            s2 = <<EOF
To request support, please select from the following support
categories.  You will be guided through the process of providing
information needed to create your request.
EOF
            puts Paint[s2, '#2794d8']
            response = nil
            loop do
              response = read_request
              break if response
            end
            return if response == :quit
            mail_body = body_from_response(response)
            mail_subject = subject_from_response(response)
            mail = Mail.new do
              to SiteConfig.contact
              body mail_body
              subject mail_subject
              from "#{Config.name} <#{options.from || Config.email}>"
            end
            puts <<EOF

========================== Your request =============================

   From: #{Config.name} <#{options.from || Config.email}>
     To: #{SiteConfig.contact}
Subject: #{mail_subject}

=====================================================================

#{mail_body}

=====================================================================
EOF
            if prompt.yes?('Send this request?')
              puts "Support request sent.\n\n"
              puts "(We would send this email here...)"
              puts mail.to_s
            else
              puts "Ok, support request cancelled!"
            end
          else
            s2 = <<EOF
This system has not been configured with a site contact email address.

Please contact your cluster administration team to make a support
request.

EOF
            puts s2
          end
        rescue TTY::Prompt::Reader::InputInterrupt
          nil
        end

        def read_request
          category = prompt.select('Support category:') do |menu|
            Category.each do |category|
              menu.choice category.title, category
            end
            menu.choice "<< Quit >>", :quit
          end
          return :quit if category == :quit
          issue = prompt.select('Request type:') do |menu|
            category.issues.each do |issue|
              menu.choice issue.title, issue
            end
            menu.choice "<< Back >>", :back
          end
          return if issue == :back
          fields = prompt.collect do
            key('Subject').ask("Subject:", default: issue.title)
            issue.fields.each do |f|
              title = "".tap do |s|
                s << f.name if f.name
                s << " (#{f.help})" if f.help
                s << ":"
              end
              k = key(f.name)
              case f.type
              when 'textarea'
                k.multiline(title)
              when 'input'
                k.ask(title)
              when 'markdown'
                k.say("NOTE: " + f.content + "\n")
              else
                nil
              end
            end
          end.reject {|k,v| k.nil?}
          {
            subject: fields.delete('Subject'),
            fields: fields,
            category: category,
            issue: issue
          }
        end

        private
        def body_from_response(response)
          <<EOF
Category:

  #{response[:category].title}

Issue type:

  #{response[:issue].title}

Fields:

EOF
          .tap do |s|
            response[:fields].each do |k,v|
              case v
              when String
                s << "  #{k}:\n\n    #{v}\n\n"
              when Array
                s << "  #{k}:\n\n"
                s << "    #{v.join("    ")}"
                s << "\n"
              end
            end
          end
        end

        def subject_from_response(response)
          "Support request: #{response[:subject]}"
        end

        def prompt
          @prompt ||= TTY::Prompt.new(help_color: :cyan)
        end
      end
    end
  end
end

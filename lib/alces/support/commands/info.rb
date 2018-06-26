require 'alces/support/site_config'
require 'alces/pretty'
require 'colorize'
require 'terminal-table'
require 'yaml'

module Alces
  module Support
    module Commands
      class Info
        def info(args, options)
          Pretty.banner('Alces Flight support request tool',
                        'v1.0.2 -- 2018-05-30')
          s2 = <<EOF
#{Paint['=============',:yellow]}
#{Paint[' Find support', :yellow, :bold]}
#{Paint['=============',:yellow]}
You can use this tool to find a support article using #{Pretty.command('alces support find')}.

EOF
          s2 <<
            <<EOF
#{Paint['=============',:yellow]}
#{Paint[' Get support', :yellow, :bold]}
#{Paint['=============',:yellow]}
EOF
          s2 <<
            if SiteConfig.emailable?
              <<EOF
You can request support from your cluster administration team by
sending an email to:

  #{Paint[SiteConfig.contact, :cyan, :bold]}

Alternatively, you can use this tool to create a support case with
your cluster administration team using #{Pretty.command('alces support request')}.

EOF
            else
              <<EOF
This system has not been configured with a site contact email address.

Please contact your cluster administration team to make a support
request.

EOF
            end
          s2 <<
            <<EOF
If you have a general question about your the Alces Flight
environment, please visit the Alces Flight Community site at:

  #{Paint['https://community.alces-flight.com', :underline, :cyan, :bold]}

For general information about how to make the most of your Alces
Flight environment, refer to the #{Pretty.command('alces about')} tool.

EOF
          puts s2
        end
      end
    end
  end
end

require 'commander/no-global-highline'
require 'alces/support/commands/find'
require 'alces/support/commands/info'
# require 'alces/support/commands/request'

module Alces
  module Support
    class CLI
      include Commander::Methods

      def run
        program :name, 'alces support'
        program :version, '0.0.1'
        program :description, 'Alces Flight support request tool'

        command :find do |c|
          c.syntax = 'support find'
          c.summary = 'Find a support article'
          c.description = 'Find a support article.'
          c.action Commands::Find, :find
        end

        command :info do |c|
          c.syntax = 'support info'
          c.summary = 'Get support information'
          c.description = 'Get support information.'
          c.action Commands::Info, :info
        end

        # command :request do |c|
        #   c.syntax = 'support request'
        #   c.summary = 'Make a support request'
        #   c.description = 'Make a support request.'
        #   c.option '--from EMAIL', 'From address'
        #   c.action Commands::Request, :request
        # end

        run!
      end
    end
  end
end

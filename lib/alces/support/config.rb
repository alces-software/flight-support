require 'xdg'

module Alces
  module Support
    module Config
      class << self
        include XDG::BaseDir::Mixin

        def root
          File.join(File.dirname(__FILE__),'..','..','..')
        end

        def center_url
          ENV['cw_CENTER_URL'] || data[:center_url] ||
            'https://staging.accounts.alces-flight.com'
        end

        def email
          data[:auth_email]
        end

        def auth_token
          data[:auth_token]
        end

        def name
          @name ||= begin
                      name_files = config.home.glob(File.join('..','name'))
                      if name_files.first
                        File.read(name_files.first).chomp
                      else
                        "Anonymous Coward"
                      end
                    end
        end
        
        private
        def data
          @data ||= load
        end

        def subdirectory
          File.join('flight','accounts')
        end

        def load
          files = config.home.glob('config.yml')
          if files.first
            YAML.load_file(files.first)
          else
            {}
          end
        end
      end
    end
  end
end

require 'yaml'

module Alces
  module Support
    class SiteConfig
      class << self
        CONFIG_FILE = File.join(
          ENV['cw_ROOT'] || '/opt/clusterware',
          'site', 'config.yml'
        )

        def exists?
          File.exists?(CONFIG_FILE)
        end

        def emailable?
          data.key?('sitecontactemail')
        end

        def contact
          if data.key?('sitecontact')
            "#{data['sitecontact']} <#{data['sitecontactemail']}>"
          else
            data['sitecontactemail']
          end
        end

        private
        def data
          @data ||=
            if exists?
              YAML.load_file(CONFIG_FILE)
            else
              {}
              {
                'sitecontact' => 'Cluster Administrator',
                'sitecontactemail' => 'clusteradmin@example.com'
              }
            end
        end
      end
    end
  end
end

require 'http'
require 'json'
require 'alces/support/errors'

module Alces
  module Support
    class API
      def fetch_topics
        center_base_url = Config.center_url.chomp('/')

        response = http.get("#{center_base_url}/topics")

        if [401, 403].include? response.status
          raise NotAuthenticatedError
        elsif !response.status.success?
          data = (JSON.parse(response) rescue {})
          if data.key?('error')
            raise TopicFetchError, data['error']
          else
            raise TopicFetchError, response.to_s
          end
        else
          JSON.parse(response.to_s)['topics']
        end
      end

      private

      def http
        h = HTTP.headers(
          user_agent: 'Flight-Support/0.0.1',
          accept: 'application/json'
        )
        if Config.auth_token
          h.cookies(flight_sso: Config.auth_token)
        else
          h
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

namespace :password_service do
  desc 'Health check the Python password strength microservice'
  task :health do
    url = ENV.fetch('PASSWORD_SERVICE_URL', 'http://127.0.0.1:8001')
    uri = URI.join(url, '/healthz')
    begin
      res = Net::HTTP.get_response(uri)
      if res.is_a?(Net::HTTPSuccess)
        puts "OK: #{res.code} #{res.body}"
      else
        warn "NOT OK: #{res.code} #{res.body}"
        exit 1
      end
    rescue => e
      warn "ERROR: #{e.class}: #{e.message}"
      exit 2
    end
  end
end


# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class PasswordStrengthClient
  DEFAULT_TIMEOUT = 1.5 # seconds

  Response = Struct.new(:ok, :label, :score, keyword_init: true)

  def self.endpoint
    ENV.fetch('PASSWORD_SERVICE_URL', 'http://127.0.0.1:8001')
  end

  def self.fail_open?
    default = if defined?(Rails) && Rails.respond_to?(:env) && Rails.env.development?
      'false' # in development, default to fail-closed so you see validation errors
    else
      'true'  # in other envs, default to fail-open for resilience
    end
    val = ENV.fetch('PASSWORD_SERVICE_FAIL_OPEN', default).to_s.downcase
    %w[1 true yes].include?(val)
  end

  def self.check(password, timeout: DEFAULT_TIMEOUT)
    uri = URI.join(endpoint, '/check')

    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = timeout
    http.read_timeout = timeout

    req = Net::HTTP::Post.new(uri.request_uri)
    req['Content-Type'] = 'application/json'
    req.body = { password: password.to_s }.to_json

    res = http.request(req)
    if res.is_a?(Net::HTTPSuccess)
      data = JSON.parse(res.body) rescue {}
      return Response.new(
        ok: !!data['ok'],
        label: data['label'],
        score: data['score']
      )
    else
      handle_service_error('non-2xx response', res)
    end
  rescue StandardError => e
    handle_service_error(e.class.name, e.message)
  end

  def self.handle_service_error(reason, detail)
    Rails.logger.warn("PasswordStrengthClient error: #{reason} #{detail}") if defined?(Rails)
    if fail_open?
      Response.new(ok: true, label: 'unknown', score: 0.0)
    else
      Response.new(ok: false, label: 'service_unavailable', score: 0.0)
    end
  end
end

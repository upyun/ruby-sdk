# encoding: utf-8
require 'restclient'
require 'base64'
require 'json'
require 'active_support/hash_with_indifferent_access'

module Upyun
  class Form < FormSupport
    include Utils
    attr_reader :options

    def initialize(password, bucket, options={timeout: 60})
      super(api_secret: password, bucket: bucket)
      @options = options
      @endpoint = ED_AUTO
    end

    def upload(file, opts={})
      base_opts = HashWithIndifferentAccess.new({
        'bucket' => @bucket,
        'save-key' => '/{year}/{mon}/{day}/{filename}{.suffix}',
        'expiration' => Time.now.to_i + 600
      })

      payload = {
        policy: policy(base_opts.merge(opts)),
        signature: signature,
        file: file.is_a?(File) ? file : File.new(file, 'rb')
      }

      rest_client.post(payload, {'User-Agent' => "Upyun-Ruby-SDK-#{VERSION}"}) do |res|
        case res.code
        when 302

          # return 302 when set 'return-url' in opts
          hds = res.headers
          body = CGI::parse(URI.parse(hds[:location]).query).reduce({}) do |memo, (k, v)|
            memo.merge!({k.to_sym => v.first})
          end

          body[:code] = body[:code].to_i
          body[:time] = body[:time].to_i
          body[:request_id] = hds[:x_request_id]
          body
        else
          body = JSON.parse(res.body, symbolize_names: true)

          # TODO Upyun have a small bug for the `code`,
          # we have to adjust it to integer
          body[:code] = body[:code].to_i
          body[:request_id] = res.headers[:x_request_id]
          body
        end
      end
    end

    def policy(opts)
      @_policy = Base64.strict_encode64(policy_json(opts))
    end

    def signature
      md5("#{@_policy}&#{@password}")
    end

    def policy_json(opts)
      policies = VALID_PARAMS.reduce({}) do |memo, e|
        (v = opts[e]) ? memo.merge!({e => v}) : memo
      end
      policies.to_json
    end

    def rest_client
      @rest_clint ||= RestClient::Resource.new("http://#{@endpoint}/#{@bucket}", options)
    end
  end
end

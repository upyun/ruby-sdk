# encoding: utf-8
require 'restclient'
require 'json'

module Upyun
  class Form < FormBase

    attr_reader :options

    def initialize(password, bucket, options={timeout: 60})
      super(api_secret: password, bucket: bucket)
      @options = options
      @endpoint = ED_AUTO
    end

    def upload(file, opts={})
      payload = {
        policy: policy(opts),
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

    def rest_client
      @rest_clint ||= RestClient::Resource.new("http://#{@endpoint}/#{@bucket}", options)
    end
  end
end

# encoding: utf-8
require 'restclient'
require 'base64'
require 'json'
require 'active_support/hash_with_indifferent_access'

module Upyun
  class Form
    include Utils

    VALID_PARAMS = %w(
      bucket
      save-key
      expiration
      allow-file-type
      content-length-range
      content-md5
      content-secret
      content-type
      image-width-range
      image-height-range
      notify-url
      return-url
      x-gmkerl-thumbnail
      x-gmkerl-type
      x-gmkerl-value
      x-gmkerl-quality
      x-gmkerl-unsharp
      x-gmkerl-rotate
      x-gmkerl-crop
      x-gmkerl-exif-switch
      ext-param
    )

    attr_accessor :bucket, :password

    def initialize(password, bucket)
      @password = password
      @bucket = bucket
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
        file: File.new(file, 'rb')
      }

      RestClient.post("http://#{@endpoint}/#{@bucket}", payload) do |res|
        case res.code
        when 302
          res
        else
          body = JSON.parse(res.body, symbolize_names: true)

          # TODO Upyun have a small bug for the `code`,
          # we have to adjust it to integer
          body[:code] = body[:code].to_i
          body
        end
      end
    end

    private
      def policy(opts)
        @_policy = Base64.encode64(policy_json(opts))
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
  end
end

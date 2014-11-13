# encoding: utf-8
require 'restclient'
require 'digest/md5'
require 'base64'
require 'json'

module UpYun
  class Form
    VALID_PARAMS = %i(
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

    attr_accessor :endpoint, :bucket, :password

    def initialize(password, opts)
      @password = password
      @endpoint = ED_AUTO
      raise ArgumentError, "bucket must be assigned" unless opts.key?(:bucket)
      @bucket = opts[:bucket]
      @opts = opts.dup
      @opts[:"save-key"] = opts[:"save-key"] || opts[:save_key] || '/{year}/{mon}/{day}/{filename}{.suffix}'
      @opts[:expiration] = opts[:expiration] || Time.now.to_i + 600
    end

    def endpoint=(ep)
      raise ArgumentError, "Valid endpoint are #{UpYun::ED_LIST}" unless UpYun::ED_LIST.member?(ep)
      @endpoint = ep
    end

    def upload(file, opts={})
      opts = @opts.merge(opts)
      payload = {policy: policy(opts), signature: signature, file: File.new(file, "rb")}
      RestClient.post("http://#{@endpoint}/#{@bucket}", payload) do |res|
        body = JSON.parse(res.body, symbolize_names: true)

        # UpYun have a small bug for the code, we have to adjust it to integer
        body[:code] = body[:code].to_i
        body
      end
    end

    private
      def policy(opts)
        @_policy = Base64.encode64(policy_json(opts))
      end

      def signature
        Digest::MD5.hexdigest("#{@_policy}&#{@password}")
      end

      def policy_json(opts)
        policies = VALID_PARAMS.reduce({}) do |memo, e|
          (v = opts[e]) ? memo.merge!({e => v}) : memo
        end
        policies.to_json
      end
  end
end

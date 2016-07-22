# encoding: utf-8
require 'base64'
require 'json'
require 'active_support/hash_with_indifferent_access'

module Upyun
  class FormBase
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

    attr_accessor :api_secret, :bucket, :password, :params
    alias_method :password, :api_secret

    def initialize(api_secret:, bucket:, params: {})
      @api_secret, @bucket, @params = api_secret, bucket, params
    end

    def policy(params={})
      opts = default_params.merge params
      @_policy = Base64.strict_encode64(policy_json opts)
    end

    def signature
      md5("#{@_policy}&#{@api_secret}")
    end

    def policy_json(opts)
      policies = VALID_PARAMS.reduce({}) do |memo, e|
        (v = opts[e]) ? memo.merge!({e => v}) : memo
      end
      policies.to_json
    end

    ##
    # 默认参数
    def default_params
      HashWithIndifferentAccess.new({
        'bucket' => @bucket,
        'save-key' => '/{year}/{mon}/{day}/{filename}{.suffix}',
        'expiration' => Time.now.to_i + 600
      }).merge @params
    end

  end
end
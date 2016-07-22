# encoding: utf-8
module Upyun
  class FormSupport

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

    attr_accessor :api_secret, :bucket, :password
    attr_reader :params
    alias :api_secret, :password

    def initialize(api_secret:, bucket:, params: {})
      @api_secret, @bucket, @params = api_secret, bucket, params
    end

  end
end
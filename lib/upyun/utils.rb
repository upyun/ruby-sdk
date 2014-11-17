require 'digest/md5'

module Upyun
  module Utils
    def md5(str)
      Digest::MD5.hexdigest(str)
    end

    def self.included(receiver)
      receiver.send(:define_method, :endpoint) { @endpoint }
      receiver.send(:define_method, :endpoint=) do |ep|
        unless Upyun::ED_LIST.member?(ep)
          raise ArgumentError, "Valid endpoints are: #{Upyun::ED_LIST}"
        end
        @endpoint = ep
      end
    end
  end
end

require 'upyun/version'
require 'upyun/utils'
require 'upyun/rest'
require 'upyun/form'
require 'upyun/form_support'

module Upyun
  DOMAIN = 'api.upyun.com'
  ED_AUTO = "v0.#{DOMAIN}"
  ED_TELECOM = "v1.#{DOMAIN}"
  ED_UNION = "v2.#{DOMAIN}"
  ED_CMCC = "v3.#{DOMAIN}"
  ED_LIST = (0..3).map { |e| "v#{e}.#{DOMAIN}" }
end

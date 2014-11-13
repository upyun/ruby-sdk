require 'upyun/version'
require 'upyun/rest'
require 'upyun/form'

module UpYun
  DOMAIN = 'api.upyun.com'
  ED_AUTO = "v0.#{DOMAIN}"
  ED_LIST = (0..3).map { |e| "v#{e}.#{DOMAIN}" }
end

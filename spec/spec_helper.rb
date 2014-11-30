require 'coveralls'
Coveralls.wear!

require 'upyun'

class String
  def self.random(length=5)
    ('a'..'z').sort_by {rand}[0, length].join
  end
end

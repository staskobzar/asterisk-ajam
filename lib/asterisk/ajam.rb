require 'asterisk/ajam/version'
require 'asterisk/ajam/session'
require 'asterisk/ajam/response'

module Asterisk

  module AJAM
    def self.connect(options)
      Session.new(options).login
    end
  end
end

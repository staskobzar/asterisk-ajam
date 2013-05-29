require 'asterisk/ajam/version'
require 'asterisk/ajam/session'
require 'asterisk/ajam/response'

module Asterisk

  module AJAM
    def self.connect(host, port, ami_user, ami_password)
      sess = Session.new host: host, port: port, ami_user: ami_user, ami_password: ami_password
      sess.login
    end
  end
end

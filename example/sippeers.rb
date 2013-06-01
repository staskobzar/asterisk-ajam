#!/usr/bin/env ruby
require 'asterisk/ajam'
require 'pp'
ajam = Asterisk::AJAM.connect :host => '127.0.0.1',
                              :ami_user => 'admin',
                              :ami_password => 'amp111'

#pp ajam.action_sippeers

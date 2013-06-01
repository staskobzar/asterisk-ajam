#!/usr/bin/env ruby
require 'asterisk/ajam'
require 'pp'
ajam = Asterisk::AJAM.connect :host => '127.0.0.1',
                              :port => 8088,
                              :ami_user => 'admin',
                              :ami_password => 'amp111',
                              :proxy_user => 'admin',
                              :proxy_pass => 'admin'

pp ajam.connected?
# actions
res = ajam.action_sippeers
pp res.list

res = ajam.action_corestatus
pp res.attribute
pp res.list

res = ajam.action_sipshowpeer peer: '5555'
pp res.attribute

# commands
res = ajam.command 'sip show peer 5555'
pp res.data

res = ajam.command 'dialplan reload'
pp res.data

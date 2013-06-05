# Asterisk::AJAM
[![Build Status](https://travis-ci.org/staskobzar/asterisk-ajam.png?branch=master)](https://travis-ci.org/staskobzar/asterisk-ajam)
[![Coverage Status](https://coveralls.io/repos/staskobzar/asterisk-ajam/badge.png?branch=master)](https://coveralls.io/r/staskobzar/asterisk-ajam?branch=master)
[![Gem Version](https://badge.fury.io/rb/asterisk-ajam.png)](http://badge.fury.io/rb/asterisk-ajam)

* * * 
This is a very simple library that allows to comunicate with [Asterisk PBX](http://www.asterisk.org/) using [Asterisk Management Interface (AMI) actions](https://wiki.asterisk.org/wiki/display/AST/Asterisk+11+AMI+Actions). 
Library communicates with AMI through HTTP(s) protocol. HTTP interface is provided by Asterisk PBX and called [AJAM](https://wiki.asterisk.org/wiki/pages/viewpage.action?pageId=4817256)

This library does not provide events interface to AMI. It only sends actions/commands and read responses back. If you need real AMI interface please, check [Adhearsion framework](http://adhearsion.com/) which is very powerful and provides a lot of functionality.

This library can use HTTTP Authentication username/password for AJAM servers behind proxy protected with basic access authentication scheme and HTTPS (SSL).


## Installation

Add this line to your application's Gemfile:

    gem 'asterisk-ajam'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install asterisk-ajam

## Usage

You can check file [example/ajam.rb](https://github.com/staskobzar/asterisk-ajam/blob/master/example/ajam.rb) for some examples (comes with source).

Simple example:
```ruby
require 'asterisk/ajam'
ajam = Asterisk::AJAM.connect :uri => 'http://127.0.0.1:8088/mxml',
                              :ami_user => 'admin',
                              :ami_password => 'passw0rd'
if ajam.connected?
	ajam.command 'dialplan reload'
    res = ajam.action_sippeers
    res.list.each {|peer| puts peer['objectname']}
end
```

List of argument options for ```Asterisk::AJAM.connect```:

* ```:uri``` URI of AJAM server. See [Asterisk documentation](https://wiki.asterisk.org/wiki/pages/viewpage.action?pageId=4817256)  which explains how to configure AJAM server.
* ```:ami_user```  AMI user username
* ```:ami_password``` AMI user password
* ```:proxy_user``` proxy username for HTTP Authentication
* ```:proxy_pass``` proxy password for HTTP Authentication

If URI scheme is "https" then library enables SSL use. Please, note that current version does not enable verify mode of Net::HTTPS ruby library so it will accept any SSL certiificates without verifications.

```Asterisk::AJAM.connect``` returns ```Asterisk::AJAM::Session``` class which provides several useful methods:

```connected?``` returns true if successfully logged in AMI

```command``` send command to AMI and read response. Example:
```ruby
ajam.command "dialplan reload"
ajam.command "core restart when convenient"
```

```action_NAME``` sends action to AMI. NAME must be replaced with AMI action name (see: [Asterisk documentation](https://wiki.asterisk.org/wiki/display/AST/Asterisk+11+AMI+Actions)). Accepts hash as an argument. Example:
```ruby
ajam.action_agents # no arguments
ajam.action_mailboxcount mailbox: "5555@default"
ajam.action_originate :channel => 'Local/local-chan@from-pstn',
    				  :application => 'MusicOnHold',
    				  :callerid => 'John Doe <5555555>'
```

Actions and Commands return ```Asterisk::AJAM::Response``` class with several methods where response data can be found:

* list
* attribute
* data

```ruby
res = ajam.action_meetmelist
pp res.list
pp res.attribute
pp res.data
```

## Using Apache proxy tutorial
As an additional security measure Apache proxy with HTTP Authentication can be used. Here is an example of Apache Virtual Host configuration as Proxy to AJAM server

```
Listen 8888
NameVirtualHost *:8888
<VirtualHost *:8888>
  <Proxy *>
    Order deny,allow
    Allow from all
    AuthName "AJAM"
    AuthType Basic
    AuthUserFile /etc/httpd/.htpasswd
    require valid-user
  </Proxy>
  ProxyPass / http://ajamhost.com:8088/
  ProxyPassReverse / http://ajamhost.com:8088/
</VirtualHost>
```

Generate password file:
```
htpasswd -b -c /etc/httpd/.htpasswd admin passw0rd
```

Connect to proxy:
```ruby
ajam = Asterisk::AJAM.connect :uri => 'http://ajamproxy.com:8888/mxml',
                              :ami_user => 'admin',
                              :ami_password => 'amp111',
                              :proxy_user => 'admin',
                              :proxy_pass => 'passw0rd'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


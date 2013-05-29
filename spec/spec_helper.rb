require 'simplecov'
require 'coveralls'
Coveralls.wear!
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "spec/"
end
require 'asterisk/ajam'

# this fixture create valid HTTPOK response 
def get_simple_httpok
  Net::HTTPOK.new 1.1, 200, 'OK'
end

def get_http_unauth
  Net::HTTPUnauthorized.new 1.1, 401, 'Unauthorized request'
end

def get_body_success_login
  %q{<ajax-response>
<response type='object' id='unknown'><generic response='Success' message='Authentication accepted' /></response>
</ajax-response>
  }
end

def get_body_failed_login
  %q{
<ajax-response>
<response type='object' id='unknown'><generic response='Error' message='Authentication failed' /></response>
</ajax-response>
  }
end

def get_body_sippeers
  %q{<ajax-response>
<response type='object' id='unknown'><generic response='Success' actionid='321321321' eventlist='start' message='Peer status list will follow' /></response>
<response type='object' id='unknown'><generic event='PeerEntry' actionid='321321321' channeltype='SIP' objectname='5555' chanobjecttype='peer' ipaddress='-none-' ipport='0' dynamic='yes' forcerport='no' videosupport='no' textsupport='no' acl='yes' status='UNKNOWN' realtimedevice='no' /></response>
<response type='object' id='unknown'><generic event='PeerEntry' actionid='321321321' channeltype='SIP' objectname='8734' chanobjecttype='peer' ipaddress='-none-' ipport='0' dynamic='yes' forcerport='yes' videosupport='no' textsupport='no' acl='yes' status='UNKNOWN' realtimedevice='no' /></response>
<response type='object' id='unknown'><generic event='PeerEntry' actionid='321321321' channeltype='SIP' objectname='8801' chanobjecttype='peer' ipaddress='-none-' ipport='0' dynamic='yes' forcerport='yes' videosupport='no' textsupport='no' acl='yes' status='UNKNOWN' realtimedevice='no' /></response>
<response type='object' id='unknown'><generic event='PeerEntry' actionid='321321321' channeltype='SIP' objectname='8803' chanobjecttype='peer' ipaddress='-none-' ipport='0' dynamic='yes' forcerport='yes' videosupport='no' textsupport='no' acl='yes' status='UNKNOWN' realtimedevice='no' /></response>
<response type='object' id='unknown'><generic event='PeerEntry' actionid='321321321' channeltype='SIP' objectname='88888' chanobjecttype='peer' ipaddress='-none-' ipport='0' dynamic='yes' forcerport='yes' videosupport='no' textsupport='no' acl='yes' status='UNKNOWN' realtimedevice='no' /></response>
<response type='object' id='unknown'><generic event='PeerEntry' actionid='321321321' channeltype='SIP' objectname='8901' chanobjecttype='peer' ipaddress='-none-' ipport='0' dynamic='yes' forcerport='yes' videosupport='no' textsupport='no' acl='yes' status='UNKNOWN' realtimedevice='no' /></response>
<response type='object' id='unknown'><generic event='PeerEntry' actionid='321321321' channeltype='SIP' objectname='8902' chanobjecttype='peer' ipaddress='-none-' ipport='0' dynamic='yes' forcerport='yes' videosupport='no' textsupport='no' acl='yes' status='UNKNOWN' realtimedevice='no' /></response>
<response type='object' id='unknown'><generic event='PeerEntry' actionid='321321321' channeltype='SIP' objectname='8903' chanobjecttype='peer' ipaddress='-none-' ipport='0' dynamic='yes' forcerport='yes' videosupport='no' textsupport='no' acl='yes' status='UNKNOWN' realtimedevice='no' /></response>
<response type='object' id='unknown'><generic event='PeerlistComplete' eventlist='Complete' listitems='8' actionid='321321321' /></response>
</ajax-response>
  }
end

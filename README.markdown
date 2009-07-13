#webbynode-api

This gem wraps the API available for the VPS hosting company
[WebbyNode](http://www.webbynode.com). Details and a preliminary
design document for the API itself are available
[here](http://howto.webbynode.com/topic.php?id=25). Functionality
is currently based on the API guide version 2.

##Notice
**All previous methods/initializers used named/ordered arguments. New API
interactions are designed to use hashes of arguments instead. Older API
models will be converted to this new design pattern soon.**

**Also, any new/improved documentation will instead be visible in the
[YARD documentation](http://rdoc.info/projects/shanesveller/webbynode-api)
hosted at [rdoc.info](http://rdoc.info).**

##Currently Supported API functionality
* Client information such as account status, contact/address info, credit
* Webby information (status) and simple actions (start, shutdown, reboot)
* List all webbies
* DNS zone information such as domain name, TTL, and status
* Creation/deletion of DNS zones

##In Development
* DNS record information such as type, data, name, id, and TTL

##Planned Features
* DNS zone/record creation, editing and deletion
* Whatever else WebbyNode gives us in the API :)

##Example Usage
###Account
    require 'webbynode-api'
    email = "example@email.com"
    api_key = "1234567890abcdef"
    @client = WebbyNode::Client.new(email, api_key)
    puts @client.firstname

###Webby
    require 'webbynode-api'
    email = "example@email.com"
    api_key = "1234567890abcdef"
    hostname = "webby1"
    # Get a single Webby's info
    @webby = WebbyNode::Webby.new(email, api_key, hostname)
    @webby.status
    @webby.shutdown
    @webby.status
    # Get a list of all Webbies
    @webbies = WebbyNode::Webby.new(email, api_key)
    puts @webbies.list

###DNS
    require 'webbynode-api'
    email = "example@email.com"
    api_key = "1234567890abcdef"
    zone_id = 123
    @dns = WebbyNode::DNS.new(email, api_key)
    pp @dns.zones
    @dns = WebbyNode::DNS.new(email, api_key, zone_id)
    pp @dns.domain
    pp @dns.records

###DNS Zone Creation/Deletion
    require 'webbynode-api'
    email = "example@email.com"
    api_key = "1234567890abcdef"
    @new_zone = WebbyNode::DNS.new_zone(:email => email, :token => api_key, :domain => "mynewdomain.com.", :ttl => 86400)
    pp @new_zone["id"]
    # => 171
    WebbyNode::DNS.delete_zone(:email => email, :token => api_key, :id => 171)
    # => true

##Copyright

Copyright (c) 2009 Shane Sveller. See LICENSE for details.
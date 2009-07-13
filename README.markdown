#webbynode-api

This gem wraps the API available for the VPS hosting company
[WebbyNode](http://www.webbynode.com). Details and a preliminary
design document for the API itself are available
[here](http://howto.webbynode.com/topic.php?id=25). Functionality
is currently based on the API guide version 2.

##Currently Supported API functionality
* Client information such as account status, contact/address info, credit
* Webby information (status) and simple actions (start, shutdown, reboot)
* List all webbies
* DNS zone information such as domain name, TTL, and status
* List of all individual records in a given DNS zone
* Creation/deletion of DNS zones
* Activation/deactivation of DNS zones

##Planned Features
* DNS record creation, editing and deletion
* Whatever else WebbyNode gives us in the API :)

##Usage and Examples

**Please visit the
[YARD documentation](http://rdoc.info/projects/shanesveller/webbynode-api)
hosted at [rdoc.info](http://rdoc.info) for usage, documentation and examples.**

##Copyright

Copyright (c) 2009 Shane Sveller. See LICENSE for details.

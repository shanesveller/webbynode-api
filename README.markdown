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
* DNS record creation and deletion

##Planned Features
* DNS record editing
* Whatever else WebbyNode gives us in the API :)

##Usage and Examples
###Command-Line Utility
This gem now includes a basic commandline utility named `webby`.
You can pass your email and token as commandline options, or place them
in a YAML file in `~/.webbynode.yml`, like so:
    email: example@email.com
    token: 123456abcdef
You can then use the commandline utility like so
    webby -a webby status webby1
    webby -a webby restart webby1
If you do not create the YAML file, the above lines might look like:
    webby -email example@email.com -token 123456abcdef -a webby status webby1
    webby -email example@email.com -token 123456abcdef -a webby restart webby1
###Gem Usage
**Please visit the
[YARD documentation](http://rdoc.info/projects/shanesveller/webbynode-api)
hosted at [rdoc.info](http://rdoc.info) for usage, documentation and examples.**

Alternately, the YARD docs can be generated and viewed locally if you have the
`yard` gem installed.
    rake yardoc
    open doc/index.html

##Copyright

Copyright (c) 2009 Shane Sveller. See LICENSE for details.

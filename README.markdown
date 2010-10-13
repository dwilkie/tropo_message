# tropo_message

tropo_message is a tiny gem that simplifies sending messages using [Tropo](http://www.tropo.com)

## Usage
### Create a new SMS ready for sending
    message = Tropo::Message.new
    message.token = "your_token"
    message.to = "13118374750"
    message.text = "message to send"

### Send the message to listener
    post("http://api.tropo.com/1.0/sessions", message.request_xml)

See also: http://blog.tropo.com/2010/09/10/how-to-sending-an-sms-using-webapi

### Receive message and responding to Tropo (inside your listener)
    tropo_session = Tropo::Generator.parse(raw_json)

    message = Tropo::Message.new(tropo_session)
    text = message.text
    tropo = Tropo::Generator.new
    tropo.message(message.response_params) do
      say :value => text
    end
    tropo.response

See also:
http://github.com/voxeo/tropo-webapi-ruby
http://blog.tropo.com/2010/09/10/how-to-sending-an-sms-using-webapi

### More documentation?
  Check out the [source](http://github.com/dwilkie/tropo_message/blob/master/lib/tropo_message.rb). It's tiny and easy to read.

### Installation
    gem install tropo_message
    require 'tropo_message'

## Copyright

Copyright (c) 2010 David Wilkie. See LICENSE for details.


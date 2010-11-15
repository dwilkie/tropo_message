module Tropo
  class Message

    attr_accessor :params, :tropo_session

    def initialize(tropo_session = {})
      @params = {}
      @tropo_session = tropo_session
    end

    # Interesting methods

    # Determines whether a message is meant for sending by checking
    # if it has session parameters. This is useful for example if you have the same
    # handler url for incoming and outgoing messages
    #
    # Example:
    #   tropo_object = Tropo::Generator.parse(raw_json)
    #   tropo_message = Tropo::Message.new(tropo_object)
    #   tropo_message.outgoing?
    #
    def outgoing?
      tropo_session["session"] && tropo_session["session"]["parameters"]
    end

    # An alternative to the constructor
    #
    # Example:
    #   tropo_object = Tropo::Generator.parse(raw_json)
    #   tropo_message = Tropo::Message.new
    #   tropo_message.parse(tropo_object)
    #
    def parse(tropo_session)
      self.tropo_session = tropo_session
    end

    # Generates xml suitable for an XML POST request to Tropo
    #
    # Example:
    #   tropo_message = Tropo::Message.new
    #   tropo_message.to = "44122782474"
    #   tropo_message.text = "Hi John, how r u today?"
    #   tropo_message.token = "1234512345"
    #
    #   tropo_message.request_xml # =>
    #   # <sessions>
    #   #   <token>1234512345</token>
    #   #   <var name="to" value="44122782474"/>
    #   #   <var name="text" value="Hi+John%2C+how+r+u+today%3F"/>
    #   # </sessions>"
    #
    def request_xml
      request_params = @params.dup
      token = request_params.delete("token")
      xml = ""
      request_params.each do |key, value|
        xml << "<var name=\"#{escape(key)}\" value=\"#{escape(value)}\"/>"
      end
      "<sessions><token>#{token}</token>#{xml}</sessions>"
    end

    # Generates a hash suitable for using to as input to:
    # Tropo::Generator#message (see: http://github.com/voxeo/tropo-webapi-ruby)
    #
    # By default, "channel" => "TEXT" and "network" => "SMS"
    # You can override these values and any other optional parameters by setting
    # their values e.g. tropo_message.channel = "VOICE"
    #
    # Example:
    #   tropo_object = Tropo::Generator.parse(raw_json)
    #
    #   tropo_object # => {
    #   #  "session" => {
    #   #    ...
    #   #    "parameters" => {
    #   #      "to" => "44122782474",
    #   #      "text" => "Hi+John%2C+how+r+u+today%3F",
    #   #      "my_favourite_food" => "Pizza"
    #   #    }
    #   #  }
    #   #}
    #
    #   tropo_message = Tropo::Message.new(tropo_object)
    #   response_params = tropo_message.response_params # => {
    #   #  "to" => "44122782474",
    #   #  "channel" => "TEXT",
    #   #  "network" => "SMS"
    #   #}
    #
    #   text = tropo_message.text
    #
    #   Tropo::Generator.new.message(response_params) do
    #     say :value => text
    #   end
    #
    def response_params
      params = {
        "to" => to,
        "channel" => channel,
        "network" => network
      }
      params.merge!("from" => from) if from
      params.merge!("timeout" => timeout) if timeout
      params.merge!("answer_on_media" => answer_on_media) if answer_on_media
      params.merge!("headers" => headers) if headers
      params.merge!("recording" => recording) if recording
      params
    end

    # Getter/Setter methods
    def action
      params["action"] || unescape(tropo_parameters["action"])
    end

    def answer_on_media
      params["answer_on_media"] || unescape(tropo_parameters["answer_on_media"])
    end

    def channel
      params["channel"] || unescape(tropo_parameters["channel"]) || "TEXT"
    end

    def from
      params["from"] || unescape(tropo_parameters["from"])
    end

    def from=(value)
      params["from"] = value
    end

    def headers
      params["headers"] || unescape(tropo_parameters["headers"])
    end

    def network
      params["network"] || unescape(tropo_parameters["network"]) || "SMS"
    end

    def recording
      params["recording"] || unescape(tropo_parameters["recording"])
    end

    def text
      params["text"] || unescape(tropo_parameters["text"])
    end

    def text=(value)
      params["text"] = value
    end

    def timeout
      params["timeout"] || unescape(tropo_parameters["timeout"])
    end

    def to
      params["to"] || unescape(tropo_parameters["to"])
    end

    def to=(value)
      params["to"] = value
    end

    def token
      params["token"] || tropo_parameters["token"]
    end

    def token=(value)
      params["token"] = value
    end

    private
      def tropo_parameters
        session = tropo_session["session"]
        parameters = session["parameters"] if session
        parameters || {}
      end

      # Performs URI escaping so that you can construct proper
      # query strings faster. Use this rather than the cgi.rb
      # version since it's faster. (Stolen from Camping).
      def escape(s)
        s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
          '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
        }.tr(' ', '+')
      end

     # Unescapes a URI escaped string. (Stolen from Camping).
      def unescape(s)
        s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n){
          [$1.delete('%')].pack('H*')
        } if s
      end

      # Return the bytesize of String; uses String#length under Ruby 1.8 and
      # String#bytesize under 1.9.
      if ''.respond_to?(:bytesize)
        def bytesize(string)
          string.bytesize
        end
      else
        def bytesize(string)
          string.size
        end
      end
  end
end


module Tropo
  class Message

    attr_accessor :params, :tropo_session

    def initialize(tropo_session = {})
      @params = {}
      @tropo_session = tropo_session
    end

    def parse(tropo_session)
      self.tropo_session = tropo_session
    end

    def token
      params["token"] || tropo_parameters["token"]
    end

    def token=(value)
      params["token"] = value
    end

    def to
      params["to"] || tropo_parameters["to"]
    end

    def to=(value)
      params["to"] = value
    end

    def channel
      params["channel"] || tropo_parameters["channel"] || 'TEXT'
    end

    def network
      params["network"] || tropo_parameters["network"] || 'SMS'
    end

    def text
      params["text"] || tropo_parameters["msg"]
    end
    alias :msg :text

    def text=(value)
      params["text"] = value
    end
    alias :msg= :text=

    def from
      params["from"] || tropo_parameters["from"]
    end

    def from=(value)
      params["from"] = value
    end

    def timeout
      params["timeout"] || tropo_parameters["timeout"]
    end

    def answer_on_media
      params["answer_on_media"] || tropo_parameters["answer_on_media"]
    end

    def headers
      params["headers"] || tropo_parameters["headers"]
    end

    def recording
      params["recording"] || tropo_parameters["recording"]
    end

    def outgoing?
      tropo_session["session"] && tropo_session["session"]["parameters"]
    end

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

    def request_xml
      request_params = @params.dup
      token = request_params.delete("token")
      xml = ""
      request_params.each do |key, value|
        xml << "<var name=\"#{escape(key)}\" value=\"#{escape(value)}\"/>"
      end
      "<sessions><token>#{token}</token>#{xml}</sessions>"
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


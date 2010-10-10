module Tropo
  class Message

    attr_accessor :params
    attr_accessor :tropo_session

    def initialize(options = {})
      @params = options[:params] || {}
      @tropo_session = options[:tropo_session] || {}
    end

    def parse(tropo_session)
      self.tropo_session = tropo_session
    end

    def token
      params["token"] || tropo_parameters["token"]
    end

    def action
      tropo_parameters["action"] || "create"
    end

    def to
      params["to"] || tropo_parameters["to"]
    end

    def channel
      params["channel"] || tropo_parameters["channel"] || 'TEXT'
    end

    def network
      params["channel"] || tropo_parameters["channel"] || 'SMS'
    end

    def text
      params["text"] || tropo_parameters["msg"]
    end
    alias :msg :text

    def from
      params["from"] || tropo_parameters["from"]
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
      params["headers"] || tropo_parameters["recording"]
    end

    def outgoing?
      tropo_parameters["action"] == "create"
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

    def request_params
      response_params.merge(
        "token" => token,
        "action" => action
      )
    end

    private
      def tropo_parameters
        session = tropo_session["session"]
        parameters = session["parameters"] if session
        parameters || {}
      end
  end
end


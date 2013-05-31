require 'net/http'
#
# = asterisk/ajam/session.rb
#
module Asterisk
  module AJAM
    #
    # == Session class for Asterisk AJAM 
    # Used to controll connection to Astersik AJAM via HTTP protocol
    #
    
    # Session errors
    # This class extends StandardError and raises when problem with
    # AJAM URL found, for ex: missing scheme or hostname
    # TODO: should be also used for HTTPS connections
    class InvalidURI < StandardError; end
    # This class extends StandardError and raises when problems
    # with loggin AJAM server found or when missing importent
    # parameters like username or password.
    class InvalidAMILogin < StandardError; end

    # Class extends StandardError and is raised when trying to
    # send command to not AJAM server where not logged in
    class NotLoggedIn < StandardError; end

    # This class establish connection to AJAM server using TCP connection
    # and HTTP protocol. 
    class Session

      # Asterisk AJAM server host or IP
      attr_accessor :host

      # Asterisk AJAM server port (default port is 8088)
      attr_accessor :port

      # AMI user name
      attr_accessor :ami_user

      # AMI password
      attr_accessor :ami_password

      # Create new Asterisk AJAM session without initializing 
      # TCP network connection
      def initialize(options={})
        @host           = options[:host]
        @port           = options[:port] || 8088
        @ami_user       = options[:ami_user]
        @ami_password   = options[:ami_password]
      end

      # login action. Also stores session identificator for 
      # sending many actions within same session
      def login
        ami_user_valid?
        ami_pass_valid?
        response = send_action :login, username: @ami_user, secret: @ami_password
        set_session_id response.session_id
        response
      end

      # send AMI command
      def command(command)
        action_command command: command
      end

      # get or set default XML Manager Event Interface URI path
      def path
        @path ||= '/mxml'
      end

      # set XML Manager Event Interface URI path
      def path=(path)
        @path = path
      end

      # AJAM URI scheme setter
      def scheme=(scheme)
        @scheme = scheme
      end

      # AJAM URI scheme getter (default: http)
      def scheme
        @scheme ||= 'http'
      end

      # Verify if session esteblished connection and set session id
      def connected?
        /^[0-9a-z]{8}$/.match(@session_id).is_a? MatchData
      end
      private
        # handling action_ methods
        def method_missing(method, *args)
          method = method.id2name
          raise NoMethodError,
            "Undefined method #{method}" unless /^action_\w+$/.match(method)
          raise NotLoggedIn, "Not logged in" unless connected?
          send_action method.sub(/^action_/,'').to_sym, *args
        end

        # send action to Asterisk AJAM server
        def send_action(action, params={})
          set_query Hash[action: action].merge params
          http_send_action
        end

        # Send HTTP request to AJAM server using "#uri"
        def http_send_action
          Net::HTTP.start(host, port) do |http|
            req  = Net::HTTP::Get.new uri.request_uri, request_headers
            Response.new http.request req
          end
        end

        # AJAM URI query segment
        def query
          @query
        end

        # set AJAM URI query segment
        def set_query(params)
          @query = URI.encode_www_form params
        end

        # set AJAM session id
        def set_session_id(sid)
          @session_id = sid
        end

        # verifies if AMI username is set and not empty
        def ami_user_valid?
          raise InvalidAMILogin,
            "Missing AMI username" if @ami_user.to_s.empty?
        end

        # verifies if AMI password (secret) is set and not empty
        def ami_pass_valid?
          raise InvalidAMILogin,
            "Missing AMI user pass" if @ami_password.to_s.empty?
        end

        # AJAM server URI
        def uri
          URI::HTTP.build host: host,  # AJAM server host
            port: port,  # AJAM port (default 8088)
            path: path,  # AMI uri path segment
            query: query # query
        end

        # initialize request headers for Net::HTTPRequest class
        def request_headers
          Hash[
            'Set-Cookie' => %Q!mansession_id="#{@session_id}"!
          ]
        end
    end
  end
end

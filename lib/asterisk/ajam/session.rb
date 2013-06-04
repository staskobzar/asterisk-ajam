require 'net/https' # this will also include net/http and uri
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
    class InvalidURI < StandardError; end #:nodoc:

    # This class extends StandardError and raises when problems
    # with loggin AJAM server found or when missing importent
    # parameters like username or password.
    class InvalidAMILogin < StandardError; end #:nodoc:

    # Class extends StandardError and is raised when trying to
    # send command to not AJAM server where not logged in
    class NotLoggedIn < StandardError; end #:nodoc:

    # This class establish connection to AJAM server using TCP connection
    # and HTTP protocol. 
    class Session

      # Asterisk AJAM server URI
      # URI class instance
      attr_accessor :uri

      # AMI user name
      attr_accessor :ami_user

      # AMI password
      attr_accessor :ami_password

      # http access user
      attr_accessor :proxy_user

      # http access password
      attr_accessor :proxy_pass

      # Create new Asterisk AJAM session without initializing 
      # TCP network connection
      def initialize(options={})
        self.uri        = options[:uri]
        @ami_user       = options[:ami_user]
        @ami_password   = options[:ami_password]
        @proxy_pass     = options[:proxy_pass]
        @proxy_user     = options[:proxy_user]
        @use_ssl        = options[:use_ssl]
      end

      # login action. Also stores session identificator for 
      # sending many actions within same session
      def login
        ami_user_valid?
        ami_pass_valid?
        send_action :login, username: @ami_user, secret: @ami_password
        self
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
        /^[0-9a-z]{8}$/.match(@response.session_id).is_a? MatchData
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
          set_params Hash[action: action].merge params
          @response = http_send_action
        end

        # Send HTTP request to AJAM server using "#uri"
        def http_send_action
          http = http_inst
          req  = http_post
          Response.new http.request req
        end

        # create new Net::HTTP instance
        def http_inst
          http = Net::HTTP.new(host, port)
          http.use_ssl = @use_ssl
          http
        end

        # create new Net::HTTP::Post instance
        def http_post
          req  = Net::HTTP::Post.new uri.request_uri, request_headers
          req.set_form_data params
          req.basic_auth @proxy_user, @proxy_pass if @proxy_pass && @proxy_user
          req
        end

        # Post parameters
        def params
          @params
        end

        # set AJAM POST parameters
        def set_params(params)
          @params = params #URI.encode_www_form params
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
            password: @proxy_pass,
            user: @proxy_user
        end

        # setup AJAM URI
        def uri=(uri)
          pp uri
          pp URI.parse(uri)
          @uri = URI.parse uri
          raise InvalidURI,
            "No AJAM URI given" unless @uri
          raise InvalidURI,
            "Unsupported protocol #{@uri.scheme}" unless %w/http https/.include? @uri.scheme
        end

        # initialize request headers for Net::HTTPRequest class
        def request_headers
          return nil unless @response
          Hash[
            'Cookie' => %Q!mansession_id="#{@response.session_id}"!
          ]
        end
    end
  end
end

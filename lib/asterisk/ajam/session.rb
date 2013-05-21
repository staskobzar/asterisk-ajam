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
    class InvalidURI < StandardError; end
    class InvalidAMILogin < StandardError; end

    class Session

      # Asterisk AJAM server host or IP
      attr_accessor :host

      # Asterisk AJAM server port (default port is 8088)
      attr_accessor :port

      # AMI user name
      attr_accessor :ami_user

      # AMI password
      attr_accessor :ami_password

      #
      # Create new Asterisk AJAM session without initializing 
      # TCP network connection
      def initialize(options={})
        @host          = options[:host] unless options[:host].nil?
        @port          = options[:port] || 8088
        @ami_user      = options[:ami_user]
        @ami_password  = options[:ami_password]
      end

      # AJAM server URI
      def uri
        raise InvalidURI, "Host not set" if host.nil?
        URI::Generic.new 'http', # scheme
                   nil,   # userinfo
                   host,
                   port,
                   nil,   # registry
                   path,
                   nil,   # opaque
                   query, # query
                   nil    # fragment
      end

      # login action. Also stores session identificator for 
      # sending many actions within same session
      def login
        raise InvalidAMILogin, "Missing AMI username" if @ami_user.nil?
        raise InvalidAMILogin, "Missing AMI user pass" if @ami_password.nil?

      end

      # send action to Asterisk AJAM server
      def send_action(action, params={})
        raise InvalidAMILogin, "Not logged in" unless valid?
        set_query Hash[action: action].merge params
        http_send_action uri
      end

      # get or set default XML Manager Event Interface URI path
      def path
        @path ||= '/mxml'
      end

      # set XML Manager Event Interface URI path
      def path=(path)
        @path = path
      end

      private
        # AJAM URI query segment
        def query
          @query
        end

        # set AJAM URI query segment
        def set_query(params)
          @query = URI.encode_www_form params
        end

        # TODO: set cookies jar
        def set_cookies(header)
          @cookies = 'TODO'
        end

        # TODO: check if session is valid
        def valid?
          !@cookies.nil?
        end
    end
  end
end

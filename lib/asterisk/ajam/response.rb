begin
  require 'libxml-ruby'
rescue LoadError
  require 'libxml'
end

#
# = asterisk/ajam/response.rb
#
module Asterisk
  module AJAM
    # Exception raised when HTTP response body is invalid
    class InvalidHTTPBody < StandardError; end # :nodoc:

    #
    # Generic class to process and store responses from
    # Asterisk AJAM server. Stores data from HTTP response
    # and xml document received from Asterisk server
    #
    class Response
      # HTTP response code
      attr_reader :code

      # AJAM session id
      attr_reader :session_id

      # Response eventlist from action (for example: sip peers)
      attr_reader :list

      # Response attributes
      attr_reader :attribute

      # Creates new Response class instance. Sets instance
      # variables from HTTP Response (like code). Parses body.
      def initialize(http)
        unless http.is_a?(Net::HTTPResponse)
          raise ArgumentError,
                "Expected Net::HTTPResponse. Got #{http.class}"
        end
        @attribute = []
        @list = []
        @code = http.code.to_i
        return unless httpok?

        parse_body http.body
        set_session_id http
      end

      # HTTP request status
      def httpok?
        @code.eql? 200
      end

      # Is AJAM action/command successful
      def success?
        @success
      end

      # opaque_data from command response
      def data
        @data || @nodes
      end

      # raw xml from command response
      attr_reader :raw_xml

      private

      # Parses HTTP response body.
      # Body should by xml string. Otherwise will raise
      # exception InvalidHTTPBody
      def parse_body(xml)
        @raw_xml = xml
        set_nodes xml
        verify_response
        set_eventlist
      end

      # parse xml body and set result to internal variable for farther processing
      def set_nodes(xml)
        if xml.to_s.empty?
          raise InvalidHTTPBody,
                'Empty response body'
        end
        src = LibXML::XML::Parser.string(xml).parse
        @nodes = src.root.find('response/generic').to_a
      end

      #
      # Check if AJAM response is successful and set internal variable
      # @success
      def verify_response
        node = @nodes.shift
        @success = %w[success follows].include? node[:response].to_s.downcase
        @attribute = node.attributes.to_h

        set_command_data
      end

      # extract mansession_id from cookies
      def set_session_id(http)
        return unless /mansession_id=(['"])([^'"]+)\1/ =~ http['Set-Cookie']

        @session_id = ::Regexp.last_match(2)
      end

      # for responses that contain eventlist of values set it to
      # internal attributes
      def set_eventlist
        return unless @attribute['eventlist'].to_s.downcase.eql? 'start'

        @nodes.each do |node|
          next if node['eventlist'].eql? 'Complete'

          @list << node.attributes.to_h
        end
      end

      def set_command_data
        return unless @attribute.has_key?('opaque_data')

        @data = @attribute['opaque_data']
        @attribute.delete 'opaque_data'
      end
    end
  end
end

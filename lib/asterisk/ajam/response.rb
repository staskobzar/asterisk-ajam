require 'libxml'

#
# = asterisk/ajam/response.rb
#
module Asterisk
  module AJAM
    # Exception raised when HTTP response body is invalid
    class InvalidHTTPBody < StandardError;end #:nodoc:

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

      # opaque_data from command response
      attr_reader :data

      # Creates new Response class instance. Sets instance 
      # variables from HTTP Response (like code). Parses body.
      def initialize(http)
        raise ArgumentError,
          "Expected Net::HTTP::Response. Got #{http.class}" unless http.is_a?(Net::HTTPResponse)
        @attribute = []
        @list = []
        @code = http.code
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

      private
        # Parses HTTP response body.
        # Body should by xml string. Otherwise will raise
        # exception InvalidHTTPBody
        def parse_body xml
          set_nodes xml
          verify_response
          set_eventlist
        end

        # parse xml body and set result to internal variable for farther processing
        def set_nodes xml
          raise InvalidHTTPBody,
            "Empty response body" if xml.to_s.empty?
          src = LibXML::XML::Parser.string(xml).parse
          @nodes = src.root.find('response/generic').to_a
        end

        # 
        # Check if AJAM response is successfull and set internal variable
        # @success
        def verify_response
          node = @nodes.shift
          @success = ['success', 'follows'].include? node[:response].to_s.downcase
          @attribute = node.attributes.to_h

          set_command_data
        end

        # extract mansession_id from cookies
        def set_session_id(http)
          if /mansession_id=(['"])([^\1]+)\1/ =~ http['Set-Cookie']
            @session_id = $2
          end
        end

        # for reponses that contain eventlist of values set it to 
        # internal attributes
        def set_eventlist
          return unless @attribute['eventlist'].to_s.downcase.eql? 'start'
          @nodes.each do |node|
            next if node['eventlist'].eql? 'Complete'
            @list << node.attributes.to_h
          end
        end

        def set_command_data
          if @attribute.has_key?('opaque_data')
            @data = @attribute['opaque_data']
            @attribute.delete 'opaque_data'
          end
        end

    end
  end
end

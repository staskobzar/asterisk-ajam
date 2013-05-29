require 'libxml'

#
# = asterisk/ajam/response.rb
#
module Asterisk
  module AJAM
    # Exception raised when HTTP response body is invalid
    class InvalidHTTPBody < StandardError;end

    #
    # Generic class to process and store responses from 
    # Asterisk AJAM server. Stores data from HTTP response
    # and xml document received from Asterisk server
    #
    class Response

      # HTTP response code
      attr_reader :code

      # Creates new Response class instance. Sets instance 
      # variables from HTTP Response (like code). Parses body.
      def initialize(http)
        raise ArgumentError,
          "Expected Net::HTTP::Response. Got #{http.class}" unless http.is_a?(Net::HTTPResponse)
        @attributes = Array[]
        @code = http.code
        return unless httpok?
        parse_body http.body
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
          #nodes.each {|n| pp n.class;pp n.attributes.to_h}
        end

        # parse xml body and set result to internal variable for farther processing
        def set_nodes xml
          raise ArgumentError,
            "Empty response body" if xml.to_s.empty?
          src = LibXML::XML::Parser.string(xml).parse
          @nodes = src.root.find('response/generic').to_a
          raise ArgumentError,
            "Invalid response body structure" if @nodes.empty?
        end

        # 
        # Check if AJAM response is successfull and set internal variable
        # @success
        def verify_response
          @success = false
          node = @nodes.first
          @success = node[:response].to_s.downcase.eql? 'success'
          attributes = node.attributes.to_h

          attributes.delete :response
          @response = attributes
        end

        # for reponses that contain eventlist of values set it to 
        # internal attributes
        def set_eventlist
          return unless @response[:eventlist].eql? 'start'

        end

    end
  end
end

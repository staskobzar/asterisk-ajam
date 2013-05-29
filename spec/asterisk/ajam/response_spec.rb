require 'spec_helper'

module Asterisk
  module AJAM
    describe Response do
      # stub successful login
      let(:res_login_ok) do
        http = get_simple_httpok
        http.stub(:body => get_body_success_login)
        http
      end
      # stub failed login
      let(:res_login_fail) do
        http = get_simple_httpok
        http.stub(:body => get_body_failed_login)
        http
      end

      #new
      describe "#new" do
        it "raises error if parameter is not Net::HTTPResponse instance" do
          expect{
            Response.new nil
          }.to raise_error(ArgumentError)
        end
      end

      #httpok?
      describe "#httpok?" do
        it "returns true if successfully received response from AJAM" do
          res = Response.new res_login_ok
          res.should be_httpok
        end
        it "returns false if response from AJAM anything but 200 OK" do
          res = Response.new get_http_unauth
          res.should_not be_httpok
        end
      end

      #success?
      describe "#success?" do
        it "returns true if AJAM response is successful" do
          res = Response.new res_login_ok
          res.should be_success
        end
        it "returns false if AJAM response id error" do
          res = Response.new res_login_fail
          res.should_not be_success
        end
      end

    end
  end
end

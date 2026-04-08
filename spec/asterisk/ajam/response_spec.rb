require 'spec_helper'

module Asterisk
  module AJAM
    describe Response do
      # stub successful login
      let(:res_login_ok) do
        http = get_simple_httpok
        allow(http).to receive(:body).and_return(get_body_success_login)
        http
      end
      # stub failed login
      let(:res_login_fail) do
        http = get_simple_httpok
        allow(http).to receive(:body).and_return(get_body_failed_login)
        http
      end

      #new
      describe "#new" do
        it "raises error if parameter is not Net::HTTPResponse instance" do
          expect{
            Response.new nil
          }.to raise_error(ArgumentError)
        end

        it "raises error if empty response body" do
          http = get_simple_httpok
          allow(http).to receive(:body).and_return('')
          expect{
            Response.new http
          }.to raise_error(InvalidHTTPBody)
        end

        it "raises error if invalid xml response body" do
          http = get_simple_httpok
          allow(http).to receive(:body).and_return('<a>this is not xml')
          expect{
            Response.new http
          }.to raise_error(LibXML::XML::Error)
        end

        it "set session id" do
          sid = "df901b5f"
          res = res_login_ok
          allow(res).to receive(:[]).with('Set-Cookie').and_return(%Q[mansession_id="#{sid}"; Version=1; Max-Age=60])
          response = Response.new res
          expect(response.session_id).to eql(sid)
        end
      end

      #httpok?
      describe "#httpok?" do
        it "returns true if successfully received response from AJAM" do
          res = Response.new res_login_ok
          expect(res).to be_httpok
        end
        it "returns false if response from AJAM anything but 200 OK" do
          res = Response.new get_http_unauth
          expect(res).not_to be_httpok
        end
      end

      #success?
      describe "#success?" do
        it "returns true if AJAM response is successful" do
          res = Response.new res_login_ok
          expect(res).to be_success
        end
        it "returns false if AJAM response id error" do
          res = Response.new res_login_fail
          expect(res).not_to be_success
        end
      end

      describe "actions" do
        it "set recieved response list to class attributes" do
          http = get_simple_httpok
          allow(http).to receive(:body).and_return(get_body_sippeers)
          res = Response.new http
          expect(res.list.first).to include('event' => 'PeerEntry', 'objectname' => '5555')
          expect(res.list.last).to include('objectname' => '8903')
        end

        it "when response has single result then it stored in :response" do
          http = get_simple_httpok
          allow(http).to receive(:body).and_return(get_body_corestatus)
          res = Response.new http
          expect(res.attribute['corestartuptime']).to eql('17:13:00')
        end
      end

      describe "#command" do
        it "set data variable with response from AJAM" do
          http = get_simple_httpok
          allow(http).to receive(:body).and_return(cmd_body_dialplan_reload)
          res = Response.new http
          expect(res.data).to match(/Dialplan reloaded/)
        end
      end
    end
  end
end

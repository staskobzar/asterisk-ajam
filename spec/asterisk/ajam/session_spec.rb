require 'spec_helper'

module Asterisk
  module AJAM
    describe Session do
      let(:uri_http){'http://ajam.asterisk.com:8088/mxml'}
      let(:manses_id){"84d22b60"}

      before(:each, :mock_login => true) do
        http = get_simple_httpok
        http.stub(:body => get_body_success_login)
        http.stub(:[]).and_return(%Q|mansession_id="#{manses_id}"; Version=1; Max-Age=60|)
        http.stub(:set_form_data).with(anything())
        http.stub(:use_ssl=)
        http.stub(:request => http)
        Net::HTTP.stub(:new => http)
        Net::HTTP::Post.stub(:new).and_return(double('Net::HTTP::Post', :set_form_data => true))
      end

      describe "#new" do
        it "set ajam uri" do
          URI.should_receive(:parse).with(uri_http)
          Session.new uri: uri_http
        end

        it "raises error if URI missing " do
          expect{
            Session.new
          }.to raise_error(InvalidURI, 'No AJAM URI given')
        end

        it "raises error if scheme is not http or https" do
          uri = "ftp://host:port/path"
          expect{
            Session.new uri: uri
          }.to raise_error(InvalidURI)
        end
      end

      describe "#path" do
        it "returns default path to /mxml" do
          subject.path.should eql('/mxml')
        end
        it "sets new path" do
          p = '/asterisk/mxml'
          subject.path = p
          subject.path.should eql(p)
        end
      end

      describe "#scheme" do
        it "default value is http" do
          subject.scheme.should == 'http'
        end
        it "set scheme" do
          subject.scheme = 'https'
          subject.scheme.should == 'https'
        end
      end

      describe "#login" do
        it "raises InvalidAMILogin if empty AMI username" do
          subject.ami_user = nil
          expect{
            subject.login
          }.to raise_error(InvalidAMILogin)
        end

        it "raises InvalidAMILogin if empty AMI password" do
          subject.ami_password = nil
          expect{
            subject.login
          }.to raise_error(InvalidAMILogin)
        end

        it "should return Session class instance on success" , :mock_login => true do
          response = subject.login
          response.should be_kind_of Session
        end

      end

      describe "#connected?" do
        it "returns true when successfuly logged in", :mock_login => true do
          subject.login
          subject.should be_connected
        end
      end

      describe "action methods" do
        before(:each) {subject.stub(:connected?).and_return(true)}
        it "when call action without parameters then expects send_action with action name" do
          subject.should_receive(:send_action).once.with(:sippeers)
          subject.action_sippeers
        end

        it "when call action with parameters then expects send_action with hash" do
          params = Hash[family: 'user', key: 'extension', val: '5555']
          subject.should_receive(:send_action).with(:dbput, params)
          subject.action_dbput params
        end

        it "uses cookies when sending action", :mock_login => true do
          Net::HTTP::Post.should_receive(:new).with(anything(),hash_including("Cookie"=>%Q!mansession_id="#{manses_id}"!))
          subject.login
          subject.action_corestatus
        end
      end

      describe "#command" do
        before(:each) {subject.stub(:connected?).and_return(true)}
        it "sends command to action method" do
          http = get_simple_httpok
          http.stub(:body => cmd_body_sip_show_peers)
          http.stub(:[]).and_return(%Q|mansession_id="#{manses_id}"; Version=1; Max-Age=60|)
          http.stub(:set_form_data).with(anything())
          http.stub(:use_ssl=)
          http.stub(:request => http)
          Net::HTTP.stub(:new => http)
          Net::HTTP::Post.stub(:new).and_return(double('Net::HTTP::Post', :set_form_data => true))
          res = subject.command 'sip show peers'
          res.data.should match(/88888\s+\(Unspecified\)/)
        end
      end

    end
  end
end

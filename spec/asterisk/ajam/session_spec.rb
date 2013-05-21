require 'spec_helper'

module Asterisk
  module AJAM
    describe Session do
      let(:options) do
        Hash[
          host:     'ajam.asterisk.com',
          port:     8088,
        ]
      end
      let(:session){Session.new}
      subject { session }
      before(:each) do
        subject.host = options[:host]
        subject.port = options[:port]
      end

      describe "#uri" do
        specify { subject.uri.should be_a_kind_of(URI) }
        it "raises InvalidURI if host is nil" do
          subject.host = nil
          expect{subject.uri}.to raise_error(InvalidURI)
        end
        it "returns valid AJAM URI if all conditions met" do
          subject.uri.to_s.should eql('http://ajam.asterisk.com:8088/mxml')
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

      describe "#login" do
        it "raises InvalidAMILogin if empty username or password" do
          subject.ami_user = nil
          subject.ami_password = nil
          expect{
            subject.login
          }.to raise_error(InvalidAMILogin)
        end

        it "stores session cookies for multiple actions within single session" do
          pending
        end
      end

      describe "#send_action" do
        before(:each, :loggedin => true) do
          subject.stub(:valid?).and_return(true)
        end

        it "raises InvalidAMILogin if not logged in" do
          expect{
            subject.send_action :login, username: 'admin', secret: 'passw0rd'
          }.to raise_error(InvalidAMILogin)
        end

        it "prepares action URI path for the action", :loggedin => true do
          subject.stub(:http_send_action).and_return(true)
          subject.send_action :login, username: 'admin', secret: 'passw0rd'
          subject.uri.query.should eql('action=login&username=admin&secret=passw0rd')
        end

        it "uses http_send_action to connect and write to server", :loggedin => true do
          subject.stub(:http_send_action).once
          subject.send_action :login, username: 'admin', secret: 'passw0rd'
        end

        it "returns Response instance", :loggedin => true do
          pending
        end
      end

    end
  end
end

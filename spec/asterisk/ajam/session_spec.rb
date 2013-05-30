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
        subject.ami_user = 'admin'
        subject.ami_password = 'passw0rd'
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

        it "should return response class with 'success' method true on success" do
          http = get_simple_httpok
          http.stub(:body => get_body_failed_login)
          Net::HTTP.stub(:start).and_yield(double('Net::HTTP', :request => http))
          Net::HTTP::Get.stub(:new).and_return(nil)
          response = subject.login
          response.should be_kind_of Response
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
        
      end

    end
  end
end

require 'spec_helper'

module Asterisk
  module AJAM
    describe Session do
      let(:uri_http) { 'http://ajam.asterisk.com:8088/mxml' }
      let(:manses_id) { '84d22b60' }
      let(:http) do
        http = get_simple_httpok
        allow(http).to receive(:body).and_return(get_body_success_login)
        allow(http).to receive(:[]).with('Set-Cookie').and_return(%(mansession_id="#{manses_id}"; Version=1; Max-Age=60))
        http
      end
      subject { Session.new uri: uri_http, ami_user: 'admin', ami_password: 'passw0rd' }
      before(:each, logginok: true) do
        allow(Net::HTTP).to receive(:new).and_return(double('Net::HTTP', :request => http, :use_ssl= => true))
      end

      describe '#new' do
        it 'set AJAM uri' do
          expect(URI).to receive(:parse).with(uri_http).and_return(URI(uri_http))
          Session.new uri: uri_http
        end

        it 'raises error if URI missing ' do
          expect do
            Session.new
          end.to raise_error(URI::InvalidURIError)
        end

        it 'raises error if scheme is not http or https' do
          uri = 'ftp://127.0.0.1/path'
          expect do
            Session.new uri: uri
          end.to raise_error(InvalidURI)
        end
      end

      describe '#login', logginok: true do
        it 'raises InvalidAMILogin if empty AMI username' do
          subject.ami_user = nil
          expect do
            subject.login
          end.to raise_error(InvalidAMILogin)
        end

        it 'raises InvalidAMILogin if empty AMI password' do
          subject.ami_password = nil
          expect do
            subject.login
          end.to raise_error(InvalidAMILogin)
        end

        it 'should return Session class instance on success', mock_login: true do
          response = subject.login
          expect(response).to be_kind_of(Session)
        end
      end

      describe '#connected?', logginok: true do
        it 'returns true when successfully logged in', mock_login: true do
          subject.login
          expect(subject).to be_connected
        end
      end

      describe 'action methods' do
        before(:each) { allow(subject).to receive(:connected?).and_return(true) }
        it 'when call action without parameters then expects send_action with action name' do
          expect(subject).to receive(:send_action).once.with(:sippeers)
          subject.action_sippeers
        end

        it 'when call action with parameters then expects send_action with hash' do
          params = Hash[family: 'user', key: 'extension', val: '5555']
          expect(subject).to receive(:send_action).with(:dbput, params)
          subject.action_dbput params
        end

        it 'uses cookies when sending action', logginok: true do
          subject.login
          expect(Net::HTTP::Post).to receive(:new)
            .with(anything, hash_including('Cookie' => %(mansession_id="#{manses_id}")))
            .and_return(double('Net::HTTPResponse', set_form_data: true))
          subject.action_corestatus
        end
      end

      describe '#command' do
        before(:each) { allow(subject).to receive(:connected?).and_return(true) }
        it 'sends command to action method' do
          http = get_simple_httpok
          allow(http).to receive(:body).and_return(cmd_body_sip_show_peers)
          allow(http).to receive(:[]).and_return(%(mansession_id="#{manses_id}"; Version=1; Max-Age=60))
          allow(http).to receive(:set_form_data).with(anything)
          allow(http).to receive(:use_ssl=)
          allow(http).to receive(:request).and_return(http)
          allow(Net::HTTP).to receive(:new).and_return(http)
          allow(Net::HTTP::Post).to receive(:new).and_return(double('Net::HTTP::Post', set_form_data: true))
          res = subject.command 'sip show peers'
          expect(res.data).to match(/88888\s+\(Unspecified\)/)
        end
      end
    end
  end
end

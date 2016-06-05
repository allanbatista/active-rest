require 'spec_helper'

module ActiveRest
  describe Authentication do
    before do
      class CustomAuthentication < Authentication
        def authenticate! path = nil, params = nil, headers = nil
          connection.headers['X-Auth-Token'] = 'SERCRET_TOKEN'
        end
      end

      module AuthenticationConnection
        extend Connection

        authentication CustomAuthentication
      end

      AuthenticationConnection.enable_stubs!
    end

    after  { AuthenticationConnection.disable_stubs! }

    context "should authenticate before all methods" do

      it "get" do
        AuthenticationConnection.stubs.get('/users', { 'X-Auth-Token' => 'SERCRET_TOKEN' }) { [200, nil, '{}'] }

        expect( AuthenticationConnection.authentication ).to receive(:authenticate!)

        AuthenticationConnection.get('/users')
      end

      it "post" do
        AuthenticationConnection.stubs.post('/users', { 'X-Auth-Token' => 'SERCRET_TOKEN' }) { [200, nil, '{}'] }

        expect( AuthenticationConnection.authentication ).to receive(:authenticate!)

        AuthenticationConnection.post('/users')
      end

      it "patch" do
        AuthenticationConnection.stubs.patch('/users', { 'X-Auth-Token' => 'SERCRET_TOKEN' }) { [204, nil, '{}'] }

        expect( AuthenticationConnection.authentication ).to receive(:authenticate!)

        AuthenticationConnection.patch('/users')
      end

      it "put" do
        AuthenticationConnection.stubs.put('/users', { 'X-Auth-Token' => 'SERCRET_TOKEN' }) { [204, nil, '{}'] }

        expect( AuthenticationConnection.authentication ).to receive(:authenticate!)

        AuthenticationConnection.put('/users')
      end

      it "delete" do
        AuthenticationConnection.stubs.delete('/users', { 'X-Auth-Token' => 'SERCRET_TOKEN' }) { [204, nil, '{}'] }

        expect( AuthenticationConnection.authentication ).to receive(:authenticate!)

        AuthenticationConnection.delete('/users')
      end
    end

    it "should not authenticate" do
      AuthenticationConnection.stubs.get('/users', {}) { [200, nil, '{}'] }

      expect( AuthenticationConnection.authentication ).not_to receive(:authenticate!)

      AuthenticationConnection.get('/users', {}, {}, false)
    end

    it "should change headers connector" do
      AuthenticationConnection.authentication.authenticate!

      expect( AuthenticationConnection.connector.headers['X-Auth-Token'] ).to eq('SERCRET_TOKEN')
    end
  end
end
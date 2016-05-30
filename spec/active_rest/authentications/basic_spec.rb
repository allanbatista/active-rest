require 'spec_helper'

module ActiveRest
  module Authentications
    describe Basic do
      before do
        module BasicAuthenticationConnection
          extend Connection

          authentication Basic, { username: 'username', password: 'password' }
        end
      end

      it "write authentication header" do
        BasicAuthenticationConnection.authentication.authenticate!
        
        expect( BasicAuthenticationConnection.connector.headers['Authentication'] ).to eq( Base64.encode64('username:password') )
      end
    end
  end
end
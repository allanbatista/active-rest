require 'spec_helper'

module ActiveRest
  describe Connection do
    it "default attribute" do
      module DefaultConnection
        extend Connection
      end

      expect( DefaultConnection.port ).to eq(80)
      expect( DefaultConnection.host ).to eq(nil)
      expect( DefaultConnection.protocol ).to eq('http')
      expect( DefaultConnection.connector ).to be_a Faraday::Connection
    end

    it "custom attributes" do
      module CustomConnection
        extend Connection

        port 443
        host 'google.com'
        protocol 'https'        
      end

      expect( CustomConnection.port ).to eq(443)
      expect( CustomConnection.host ).to eq('google.com')
      expect( CustomConnection.protocol ).to eq('https')
    end

    it "should writer headers" do
      module HeadersConnection
        extend Connection

        headers({ "Content-Type" => "application/json" })
      end

      expect( HeadersConnection.connector.headers ).to eq({ "User-Agent"=>"Faraday v0.9.2", "Content-Type" => "application/json" })
    end
  end
end
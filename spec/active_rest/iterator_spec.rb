require 'spec_helper'

module ActiveRest
  describe Iterator do

    before do
      module UserConnection
        extend Connection

        host 'localhost'
      end

      class User
        include ActiveRest::Model
        include ActiveRest::Model::Parser::JSON

        connection UserConnection

        field :id     , type: Integer
        field :name   , type: String
        field :idade  , type: Integer

        ##
        # default somente é valido quando esta sendo criado localmente o atrituo e depois enviado para a
        # api, porem quando é feito um load, é priorizado o valor remoto.
        field :wallet , type: Float, default: 0.0
        field :things , type: Array, default: [], remote_name: 'outher_things'

        route :list   , '/users', success: 200..299, method: :get, options: { offset: 'page', limit: 'per_page' }
        route :find   , '/users/:id', success: ((200..299).to_a + [404]), method: :get
        route :create , '/users', success: 201, method: :post, data_type: :json
        route :update , '/users/:id', success: 204, method: :patch, data_type: :json
        route :destroy, '/users/:id', success: 204, method: :delete
      end

      UserConnection.enable_stubs!
    end

    after  { UserConnection.disable_stubs! }

    it "should default options" do
      iterator = Iterator.new( User )
      
      expect( iterator.limit ).to eq( 20 )
      expect( iterator.offset ).to eq( 1 )
    end
    
    it "should implement decorator on options" do
      iterator = Iterator.new( User )
      iterator.limit( 50 ).offset( 1 )

      expect( iterator.limit ).to eq( 50 )
      expect( iterator.offset ).to eq( 1 )
    end

    it "should implement as lazy" do
      users = User.all

      UserConnection.stubs.verify_stubbed_calls
    end

    it "should implement each" do
      UserConnection.stubs.get('/users?page=1&per_page=1') { [200, {}, '[{"id":1,"name":"Allan","idade":24,"outher_things":["oi"]}]'] }
      UserConnection.stubs.get('/users?page=2&per_page=1') { [200, {}, '[{"id":2,"name":"Lucas","wallet":25.75}]'] }
      UserConnection.stubs.get('/users?page=3&per_page=1') { [200, {}, '[]'] }

      users = []
      
      User.all.limit(1).each do |user|
        users << user
      end

      expect( users.size ).to eq(2)

      expect(users[0].id).to eq(1)
      expect(users[0].name).to eq('Allan')

      expect(users[1].id).to eq(2)
      expect(users[1].name).to eq('Lucas')

      UserConnection.stubs.verify_stubbed_calls
    end

    it "should implement to_a" do
      UserConnection.stubs.get('/users?page=1&per_page=1') { [200, {}, '[{"id":1,"name":"Allan","idade":24,"outher_things":["oi"]}]'] }
      UserConnection.stubs.get('/users?page=2&per_page=1') { [200, {}, '[{"id":2,"name":"Lucas","wallet":25.75}]'] }
      UserConnection.stubs.get('/users?page=3&per_page=1') { [200, {}, '[]'] }

      users = User.all.limit(1).to_a      

      expect( users.size ).to eq(2)

      expect(users[0].id).to eq(1)
      expect(users[0].name).to eq('Allan')

      expect(users[1].id).to eq(2)
      expect(users[1].name).to eq('Lucas')

      UserConnection.stubs.verify_stubbed_calls
    end

  end
end
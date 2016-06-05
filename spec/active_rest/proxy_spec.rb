require 'spec_helper'

module ActiveRest
  describe Proxy do

    context "connection" do
      before do
        module UserConnection
          extend Connection

          host 'localhost'
        end

        class User
          include ActiveRest::Model
          include ActiveRest::Model::BasicJsonParser

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

      it "should create model with connection" do
        expect( User.connection.host ).to eq('localhost')
        expect( User.new.respond_to?(:connection) ).to eq(false)

        UserConnection.stubs.verify_stubbed_calls
      end

      context ".list" do
        it "should intialize correct route" do
          route = User.proxy.routes[:list]

          expect( route ).to be_a Route
          expect( route.path    ).to eq( '/users' )
          expect( route.success ).to eq( 200..299 )
          expect( route.method  ).to eq( :get )
          expect( route.options ).to eq({ offset: 'page', limit: 'per_page' })
        end
        
        it "should list users" do
          UserConnection.stubs.get('/users?page=1&per_page=20') { [200, {}, '[{"id":1,"name":"Allan","idade":24,"outher_things":["oi"]},{"id":2,"name":"Lucas","wallet":25.75}]'] }

          users = User.all.to_a

          expect( users.size ).to eq(2)
          expect( users.first.name ).to eq('Allan')
          expect( users.first.idade ).to eq(24)
          expect( users.first.wallet ).to eq(0.0)
          expect( users.first.things ).to eq(['oi'])
          expect( users.last.name ).to eq('Lucas')
          expect( users.last.idade ).to eq(nil)
          expect( users.last.wallet ).to eq(25.75)
          expect( users.last ).to be_persisted

          UserConnection.stubs.verify_stubbed_calls
        end

        it "should return ServerError" do
          UserConnection.stubs.get('/users?page=1&per_page=20') { [500, {}, nil] }

          expect { User.all.to_a }.to raise_error ActiveRest::Error::ResponseError

          UserConnection.stubs.verify_stubbed_calls
        end
      end

      context ".find" do
        it "get user" do
          UserConnection.stubs.get('/users/1') { [200, {}, '{"id":1,"name":"Allan","idade":24,"outher_things":["oi"]}'] }

          user = User.find({ id: 1 })

          expect( user.name ).to eq('Allan')
          expect( user.idade ).to eq(24)
          expect( user.wallet ).to eq(0.0)
          expect( user.things ).to eq(['oi'])

          UserConnection.stubs.verify_stubbed_calls
        end

        it "get user" do
          UserConnection.stubs.get('/users/2') { [299, {}, '{"id":2,"name":"Allan","idade":24,"outher_things":["oi"]}'] }

          user = User.find({ id: 2 })

          expect( user.name ).to eq('Allan')
          expect( user.idade ).to eq(24)
          expect( user.wallet ).to eq(0.0)
          expect( user.things ).to eq(['oi'])

          UserConnection.stubs.verify_stubbed_calls
        end

        it "not found" do
          UserConnection.stubs.get('/users/55') { [404, {}, ''] }

          user = User.find({ id: 55 })

          expect( user ).to be_nil

          UserConnection.stubs.verify_stubbed_calls
        end

        it "server error" do
          UserConnection.stubs.get('/users/666') { [500, {}, ''] }

          expect {
            user = User.find({ id: 666 })
          }.to raise_error(ActiveRest::Error::ResponseError)

          UserConnection.stubs.verify_stubbed_calls
        end
      end

      context "#reload" do
        it "reload with success" do
          UserConnection.stubs.get('/users/1') { [200, {}, '{"id":1,"name":"Allan","idade":24,"outher_things":["oi"]}'] }

          user = User.new(id: 1)
          user.reload

          expect( user.name ).to eq('Allan')
          expect( user.idade ).to eq(24)
          expect( user.wallet ).to eq(0.0)
          expect( user.things ).to eq(['oi'])

          UserConnection.stubs.verify_stubbed_calls
        end

        it "not found" do
          UserConnection.stubs.get('/users/1') { [404, {}, nil] }

          user = User.new(id: 1)
          user.reload

          expect( user ).to be_errors
          expect( user.errors.first ).to eq(ActiveRest::Response.messages(404))

          UserConnection.stubs.verify_stubbed_calls
        end

        it "server error" do
          UserConnection.stubs.get('/users/666') { [500, {}, nil] }

          user = User.new(id: 666)

          expect {
            user.reload
          }.to raise_error(ActiveRest::Error::ResponseError)

          UserConnection.stubs.verify_stubbed_calls
        end
      end

      context "#save" do
        it "create" do
          UserConnection.stubs.post('/users') { [201, {}, '{"id":1,"name":"Allan"}'] }

          user = User.new(name: "Allan")

          expect( user.save ).to eq(true)
          expect( user.id   ).to eq(1)
          expect( user.name ).to eq('Allan')

          UserConnection.stubs.verify_stubbed_calls
        end

        it "update" do
          UserConnection.stubs.patch('/users/1') { [204, {}, nil] }

          user = User.new(id: 1, name: "Allan")
          user.wallet = 15.0
          user.persist!

          expect( user.save ).to eq(true)

          UserConnection.stubs.verify_stubbed_calls
        end

        it "put" do
          class User
            include ActiveRest::Model

            connection UserConnection

            field :id     , type: Integer
            field :name   , type: String
            field :idade  , type: Integer

            ##
            # default somente é valido quando esta sendo criado localmente o atrituo e depois enviado para a
            # api, porem quando é feito um load, é priorizado o valor remoto.
            field :wallet , type: Float, default: 0.0
            field :things , type: Array, default: [], remote_name: 'outher_things'

            route :list  , '/users', success: 200..299, method: :get, options: { offset: 'page', limit: 'per_page' }
            route :find  , '/users/:id', success: ((200..299).to_a + [404]), method: :get
            route :create, '/users', success: 201, method: :post, data_type: :json
            route :update, '/users/:id', success: 204, method: :put, data_type: :json
          end

          UserConnection.stubs.put('/users/1') { [204, {}, nil] }

          user = User.new(id: 1, name: "Allan")
          user.wallet = 15.0
          user.persist!

          expect( user.save ).to eq(true)

          UserConnection.stubs.verify_stubbed_calls
        end
      end

      context "#destroy" do
        it "should destroy" do
          UserConnection.stubs.delete('/users/1') { [204, {}, nil] }

          user = User.new(id: 1)

          expect( user.destroy ).to eq(true)

          UserConnection.stubs.verify_stubbed_calls
        end
      end

      context ".resources" do
        before do
          class Brand
            include ActiveRest::Model

            resources '/api/v1/brands', offset: 'page', limit: 'per_page'
          end
        end

        it "deve criar todos os resources sem a necessidade de criar definir todas as rotas" do
          expect( Brand.proxy.routes[:list] ).not_to be_nil
          expect( Brand.proxy.routes[:find] ).not_to be_nil
          expect( Brand.proxy.routes[:create] ).not_to be_nil
          expect( Brand.proxy.routes[:update] ).not_to be_nil
          expect( Brand.proxy.routes[:destroy] ).not_to be_nil
        end
      end

      context "belongs_to" do

        before do
          module ::BelongsToConnection
            extend Connection

            enable_stubs!
            host 'localhost'
          end

          class ::Brand
            include ActiveRest::Model
            include ActiveRest::Model::BasicJsonParser

            connection BelongsToConnection

            field :id, type: String 
            field :name, type: String

            resources '/brands'
          end

          class ::Product
            include ActiveRest::Model
            include ActiveRest::Model::BasicJsonParser

            connection BelongsToConnection

            belongs_to :brand

            field :id, type: String
            field :name, type: String

            resources '/products'
          end

        end

        it "should find get brand" do
          BelongsToConnection.stubs.get('/brands/111') { [200, {}, { id: '111', name: 'Apple' }.to_json] }

          product = Product.new(id: '123', name: 'Smartphone', brand_id: '111')

          expect( product.brand.id ).to eq( '111' )
          expect( product.brand.name ).to eq( 'Apple' )

          BelongsToConnection.stubs.verify_stubbed_calls
        end

        it "should not found" do
          BelongsToConnection.stubs.get('/brands/NOT_FOUND') { [404, {}, ''] }

          product = Product.new(id: '123', name: 'Smartphone', brand_id: 'NOT_FOUND')

          expect( product.brand ).to be_nil

          BelongsToConnection.stubs.verify_stubbed_calls
        end

        it "should raise error" do
          BelongsToConnection.stubs.get('/brands/222') { [500, {}, ''] }

          product = Product.new(id: '123', name: 'Smartphone', brand_id: '222')

          expect { product.brand }.to raise_error ActiveRest::Error::ResponseError

          BelongsToConnection.stubs.verify_stubbed_calls
        end
      end

      context "has_many" do
        before do
          module ::HasManyConnection
            extend Connection

            enable_stubs!
            host 'localhost'
          end

          class ::Tag
            include ActiveRest::Model
            include ActiveRest::Model::BasicJsonParser

            connection HasManyConnection

            belongs_to :post

            field :id, type: String
            field :key, type: String
            field :post_id, type: String

            route :list, '/posts/:post.id/tags', method: :get, success: 200, options: { offset: 'page', limit: 'per_page' }
          end

          class ::Post
            include ActiveRest::Model
            include ActiveRest::Model::BasicJsonParser

            connection HasManyConnection

            has_many :tags, class_name: 'Tag'

            field :id, type: String
            field :title, type: String
            field :body, type: String

            resources '/posts'
          end
        end

        it "should return a list of tags" do
          HasManyConnection.stubs.get('/posts/123/tags?page=1&per_page=20') { [200, {}, [{ id: '1', key: 'color', post_id: '123' }, { id: '2', key: 'size', post_id: '123' }, { id: '3', key: 'gender', post_id: '123' }].to_json] }
          HasManyConnection.stubs.get('/posts/123') { [200, {}, {id: '123', title: 'My Blog Post', body: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Perferendis quaerat fugiat libero nemo, aspernatur soluta facere est asperiores autem possimus, voluptas, pariatur. Accusamus eveniet, aut aliquam suscipit perferendis sapiente eaque!'}.to_json] }

          post = Post.new( id: '123', title: 'My Blog Post', body: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Perferendis quaerat fugiat libero nemo, aspernatur soluta facere est asperiores autem possimus, voluptas, pariatur. Accusamus eveniet, aut aliquam suscipit perferendis sapiente eaque!' )
          
          tags = post.tags.to_a

          expect( tags.size ).to eq(3)
          expect( tags[0].id ).to eq('1')
          expect( tags[0].key ).to eq('color')
          expect( tags[1].id ).to eq('2')
          expect( tags[1].key ).to eq('size')
          expect( tags[2].id ).to eq('3')
          expect( tags[2].key ).to eq('gender')

          new_post = tags.first.post

          expect( new_post.id ).to eq(post.id)
          expect( new_post.title ).to eq(post.title)
          expect( new_post.body ).to eq(post.body)

          HasManyConnection.stubs.verify_stubbed_calls
        end
      end
    end
  end
end
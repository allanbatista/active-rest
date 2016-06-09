require 'spec_helper'

module ActiveRest
  describe Model do

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

          field :id    , type: Integer, remote_name: 'sku', remote_type: String
          field :name
          field :idade , type: Integer
          field :wallet, type: Float, default: 0.0
          field :things, type: Array, default: [], remote_name: 'outher_things'
        end
      end

      it "should translate correct" do
        user = User.new id: '1', name: 'Allan', idade: '24'

        expect( user.id ).to eq(1)
        expect( user.name ).to eq('Allan')
        expect( user.idade ).to eq(24)
        expect( user.wallet ).to eq(0.0)
      end

      context "attributes" do
        it "should create corrrect attributes" do
          attributes = User.attributes

          expect( attributes.size ).to eq(5)
          expect( attributes[:id].name ).to eq( :id )
          expect( attributes[:id].default ).to eq( nil )
          expect( attributes[:id].type ).to eq( Integer )
          expect( attributes[:id].remote_name ).to eq( 'sku' )
          expect( attributes[:id].remote_type ).to eq( String )
        end

        context "#field" do
          class Thing
            include ActiveRest::SimpleModule
            include ActiveRest::Model::BasicJsonParser

            field :key, type: String
            field :value, type: String
          end

          class ActiveRestCollectionTest
            include ActiveRest::Model
            include ActiveRest::Model::BasicJsonParser

            field :id    , type: Integer
            field :things, type: Array, as: Thing, default: []
          end

          it "Array with class" do
            rest = ActiveRestCollectionTest.new

            rest.things << Thing.new({ key: 'nome', value: 'Allan' })

            expect( rest.to_remote ).to eq({
              'id' => nil,
              'things' => [
                'key' => 'nome',
                'value' => 'Allan'
              ]
            })
          end
        end

        context "#from_remote" do
          it "should initialize correct" do
            user = User.new

            expect( user.id ).to eq(nil)
            expect( user.name ).to eq(nil)

            user.from_remote({ 'sku' => '1', 'name' => 'Allan' })

            expect( user.id ).to eq(1)
            expect( user.name ).to eq('Allan')
          end

          it "should ignore attributes that not defined" do
            user = User.new

            expect {
              user.from_remote({ 'sku' => '1', 'name' => 'Allan', 'NOT_EXISTS' => 'NOT' })
            }.not_to raise_error
          end
        end

        context "#to_remote" do
          it "should translate correct" do
            user = User.new id: 2, name: 'Lucas', things: ['tag1', 'tag2']

            expect( user.to_remote ).to eq( { 'sku' => '2', 'name' => 'Lucas', 'idade' => nil, 'wallet' => 0.0, 'outher_things' => ['tag1', 'tag2'] } )
          end
        end
      end
    end
  end
end
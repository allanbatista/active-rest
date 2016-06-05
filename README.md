# ActiveRest

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_rest', github: 'allanbatista/active-rest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_rest

## Usage

This Gem was created to make integrate with rest api easy.

### Create a Connection

A Authentication are used to permit a encapsuled a authentication API with pattern Singleton.

    require 'active_rest'

    class SkyhubAuthentication < ActiveRest::Authentication
      def authenticate! path = nil, params = nil, headers = nil
        connection.headers['X-User-Email'] = 'email@example.com.br'
        connection.headers['X-User-Token'] = 'token'
        true
      end
    end

A Connection are used do explain where and how the API should be connect.

    require 'active_rest'

    module SkyhubConnection
      extend Connection
      authentication SkyhubAuthentication
      port 443
      host 'in.skyhub.com.br'
      protocol 'https'
    end

Create a resource

    require 'active_rest'

    module SkyhubApi
      class SkyhubProduct
        include ActiveRest::Model

        connection SkyhubConnection
        resources '/products', options: { offset: 'page', limit: 'per_page' }
        route :update , "/products/:id", { method: 'put' , success: 204 }

        field :id, type: String, remote_name: 'sku'
        field :name, type: String
        field :description, type: String
        field :status, type: String, default: 'enabled'
        field :brand , type: String
        field :ean, type: String
        field :nbm, type: String
        field :qty, type: Integer, default: 0
        field :price, type: 0.0
        field :promotional_price, type: Float, default: 0.0
        field :cost, type: Integer
        field :weight, type: Float, default: 0.0
        field :height, type: Float, default: 0.0
        field :length, type: Float, default: 0.0
        field :width , type: Float, default: 0.0
        field :images, type: Array, default: []
        field :specifications, type: Array, default: []

        def self.parse action, body
          if action.to_s == 'list'
            parsed = JSON.parse(body)
            parsed['products']
          elsif ['create', 'update'].include?(action.to_s)
            {}
          else
            JSON.parse(body)
          end
        end
      end
    end

After that definations, are possível start to use.

    products = Product.all

    products.each do |product|
      product.name #=> "Product Name"
      product.name = "New Product Name"
      product.save #=> true | false
    end

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


# ActiveRest

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_rest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_rest

## Usage

### Create a Connection

A Authentication are used to permit a encapsuled a authentication API.

    require 'active_rest'

    class SkyhubAuthentication < Authentication
      def authenticate! path = nil, params = nil, headers = nil
        connection.headers['X-Auth-Token'] = 'SERCRET_TOKEN'
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

    class Product
      include ActiveRest::Model

      connection UserConnection
      parser :json

      field :id     , type: String
      field :name   , type: String
      field :idade  , type: Integer

	  resources :products
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


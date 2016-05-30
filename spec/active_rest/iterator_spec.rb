require 'spec_helper'

module ActiveRest
  describe Iterator do
    
    it "should implement decorator on options" do
      class MyModel
        extend ActiveRest::Model
      end

      iterator = Iterator.new( MyModel )
      iterator.limit( 50 ).offset( 1 )

      expect( iterator.limit ).to eq( 50 )
      expect( iterator.offset ).to eq( 1 )
    end

  end
end
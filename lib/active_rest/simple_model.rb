module ActiveRest
  ##
  # This is project to not do things external, just use field to make lists as objects
  #
  # Exemple
  #
  #     class Thing
  #         include ActiveRest::SimpleModel
  #         field :name, type: String
  #     end
  module SimpleModel
    extend  ActiveSupport::Concern

    include ActiveRest::Model::Field
    include ActiveRest::Model::Initialize
  end
end
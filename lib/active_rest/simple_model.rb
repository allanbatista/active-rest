module ActiveRest
  ##
  # This is project to not do things external, just use field to make lists as objects
  #
  # Exemple
  #
  #     class Thing
  #         include ActiveRest::SimpleModule
  #         field :name, type: String
  #     end
  module SimpleModule
    extend  ActiveSupport::Concern

    include ActiveRest::Model::Field
    include ActiveRest::Model::Initialize
  end
end
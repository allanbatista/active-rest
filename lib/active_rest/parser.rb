module ActiveRest
  module Parser
    def self.parse type, text
      class_name = ActiveRest.capitalize(type)
      self.const_get(class_name).parse(text)
    end
  end
end
module ActiveRest
  module ProxyHelper
    def self.replace_path_attributes object, path       
      splited = path.split('/')

      new_path = splited.map do |key|
        if key[0] == ':'
          key_spplited = key.gsub(':', '').split('.')
          
          new_key = key_spplited.shift
          if object.is_a? Hash
            new_value = object[new_key.to_s] || object[new_key.to_sym]
          else
            new_value = object.send(new_key)
          end

          key_spplited.each do |k|
            new_value = new_value.send(k)
          end

          new_value
        else
          key
        end
      end

      new_path.join('/')
    end
  end
end
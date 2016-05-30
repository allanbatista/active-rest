require "active_support"
require "active_support/inflector"
require "active_rest/version"
require "active_rest/response"
require "active_rest/connection"
require "active_rest/authentication"
require "active_rest/authentications/basic"
require "active_rest/route"
require "active_rest/proxy"
require "active_rest/parser"
require "active_rest/parsers/json"
require "active_rest/model/error"
require "active_rest/model/field"
require "active_rest/model/belongs_to"
require "active_rest/model/has_many"
require "active_rest/model/proxy"
require "active_rest/model"
require "active_rest/iterator"
require "active_rest/error"
require "active_rest/errors/response_error"

module ActiveRest
  def self.capitalize str
    str.to_s.split('_').collect(&:capitalize).join
  end
end

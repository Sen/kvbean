require 'redis'

$:.unshift(File.dirname(__FILE__))
require "kvbean/ext/array"

module Kvbean
  class InvalidRecord < StandardError; end
end

module Kvbean
  autoload :Redis,       'kvbean/redis'
  autoload :Base,        'kvbean/base'
  autoload :Validations, 'kvbean/validations'
  autoload :Callbacks,   'kvbean/callbacks'
  autoload :Observing,   'kvbean/observing'
  autoload :Timestamp,   'kvbean/timestamp'
end

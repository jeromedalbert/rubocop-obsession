require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'
require 'rubocop'

require_relative 'cop/obsession/mixin/helpers'
Dir["#{__dir__}/cop/obsession/**/*.rb"].sort.each { |file| require file }
require_relative 'obsession/version'
require_relative 'obsession/plugin'

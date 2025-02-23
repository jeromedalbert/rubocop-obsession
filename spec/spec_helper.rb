require 'rubocop/obsession'
require 'rubocop/rspec/support'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include RuboCop::RSpec::ExpectOffense
end

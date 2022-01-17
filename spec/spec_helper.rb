require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = :random
end

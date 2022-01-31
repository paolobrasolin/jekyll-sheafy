require "byebug" # I might as well keep it

require "simplecov"

if ENV.fetch("CC_TEST_REPORTER_ID", nil)
  require "simplecov_json_formatter"
else
  require "simplecov-html"
  require "simplecov-lcov"
  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.output_directory = "coverage"
    c.lcov_file_name = "lcov.info"
  end
end

SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch

  if ENV.fetch("CC_TEST_REPORTER_ID", nil)
    formatter SimpleCov::Formatter::JSONFormatter
  else
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::LcovFormatter,
    ])
  end
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = :random
end

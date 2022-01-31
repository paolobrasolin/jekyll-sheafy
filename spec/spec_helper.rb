require "simplecov"
require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.output_directory = "coverage"
  c.lcov_file_name = "lcov.info"
end

SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch
  formatter SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::LcovFormatter,
      SimpleCov::Formatter::HTMLFormatter,
    ]
  )
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = :random
end

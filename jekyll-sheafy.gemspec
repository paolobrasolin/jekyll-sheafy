require_relative "lib/jekyll/sheafy/version"

GH_URL = "https://github.com/paolobrasolin/jekyll-sheafy"

Gem::Specification.new do |spec|
  spec.name = "jekyll-sheafy"
  spec.version = Jekyll::Sheafy::VERSION
  spec.authors = ["Paolo Brasolin"]
  spec.email = ["paolo.brasolin@gmail.com"]

  spec.summary = "Brew your own Stacks Project with Jekyll!"
  spec.description = "This Jekyll plugin is heavily inspired by Gerby, the tool used to build the Stacks Project and Kerodon. It allows you to build math textbooks as static websites which require no complex infrastructure to run."

  spec.homepage = GH_URL
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata = {
    "bug_tracker_uri" => "#{GH_URL}/issues",
    "changelog_uri" => "#{GH_URL}/blob/main/CHANGELOG.md",
    "documentation_uri" => "#{GH_URL}#readme",
    "homepage_uri" => spec.homepage,
    # "mailing_list_uri"  => nil,
    "source_code_uri" => GH_URL.to_s,
  # "wiki_uri"          => nil,
  # "funding_uri"       => nil,
  }

  spec.files = Dir["lib/**/*.rb", "*.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", [">= 3", "< 5"]

  spec.add_development_dependency "byebug", "~> 11.1.3"
  spec.add_development_dependency "guard-rspec", "~> 4.7.3"
  spec.add_development_dependency "guard", "~> 2.18.0"
  spec.add_development_dependency "rspec", "~> 3.10.0"
  spec.add_development_dependency "rufo", "~> 0.13.0"
  spec.add_development_dependency "simplecov-lcov", "~> 0.8.0"
  spec.add_development_dependency "simplecov", "~> 0.21.2"
end

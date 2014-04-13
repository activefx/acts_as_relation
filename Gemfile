source "https://rubygems.org"

# Run tests against a specific version of associated Rails libraries
# export RAILS_VERSION=4.1.0; bundle update; bundle exec rake spec

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "master"
  {github: "rails/rails"}
when "default"
  "~> 4.0"
else
  "~> #{rails_version}"
end

gem 'activerecord', rails
gem 'activesupport', rails

# Specify your gem's dependencies in gemspec
gemspec




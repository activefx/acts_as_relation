# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |s|

  s.name        = 'acts_as_relation'
  s.version     = ActiveRecord::ActsAsRelation::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Hassan Zamani'
  s.email       = 'hsn.zamani@gmail.com'
  s.homepage    = 'http://github.com/hzamani/acts_as_relation'
  s.summary     = 'Easy multi-table inheritance for rails'
  s.description = "This 'acts_as' extension provides multi-table inheritance for rails models."

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'activerecord', '~> 4.0'
  s.add_dependency 'activesupport', '~> 4.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'

end


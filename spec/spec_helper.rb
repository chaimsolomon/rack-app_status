SPEC_DIR = File.expand_path("..", __FILE__)
lib_dir = File.expand_path("../lib", SPEC_DIR)

$LOAD_PATH.unshift(lib_dir)
$LOAD_PATH.uniq!

require 'rspec'
require 'pry'
require 'bundler'

if ENV['COVERAGE'] && (RUBY_VERSION.split('.').map(&:to_i) <=> [1,9]) >= 0
  require 'simplecov'
  SimpleCov.start do
    add_filter 'lib/google'
    add_filter 'spec/google'
  end
end

Bundler.setup

Dir["#{SPEC_DIR}/support/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
end

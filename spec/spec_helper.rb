# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'rspec/its'
require 'pry-rails'
require 'pry-byebug'

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path('../dummy/db/migrate/', __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Prepare Factory Girl
require 'factory_girl'
Dir["#{File.dirname(__FILE__)}/factories/**/*.rb"].each { |f| require f }

# Matchers
require 'accept_values_for'
require 'shoulda'

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec

  # Fixtures
  config.use_transactional_fixtures = true

  # Legacy
  config.infer_spec_type_from_file_location!
end

# NOTE: only needed for Ruby < 2.2
# prevent Test::Unit's AutoRunner from executing during RSpec's rake task
Test::Unit.run = true if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)

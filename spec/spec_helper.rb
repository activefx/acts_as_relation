require 'rspec'
require 'sqlite3'
require 'active_record'
require 'active_support'
require 'protected_attributes'

require 'acts_as_relation'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

logger = ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))
ActiveRecord::Base.default_timezone = :utc

begin
  old_logger_level, logger.level = logger.level, ::Logger::ERROR
  ActiveRecord::Migration.verbose = false
  # Load Schema
  load(File.dirname(__FILE__) + '/schema.rb')
  # Load Models
  basedir = File.dirname(__FILE__) + '/models'
  Dir["#{basedir}/*.rb"].each do |path|
    name = "#{File.basename(path, '.rb')}"
    autoload name.classify.to_sym, "#{basedir}/#{name}"
  end
ensure
  logger.level = old_logger_level
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # Wrap each spec in a transaction to roll back all the database changes
  # after each spec is run
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each { |f| require f }

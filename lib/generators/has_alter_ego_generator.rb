require 'rails/generators'
require 'rails/generators/migration'

class HasAlterEgoGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def copy_files(*args)
    empty_directory('db/fixtures/alter_egos')
    migration_template File.join(File.dirname(__FILE__), "..", "..", "generators", "has_alter_ego", "templates", "create_alter_egos.rb"),
                                 "db/migrate/create_alter_egos.rb"
  end

  def self.next_migration_number dirname
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end
end
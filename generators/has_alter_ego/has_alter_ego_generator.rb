class HasAlterEgoGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory('db/fixtures/alter_egos')
      m.migration_template('create_alter_egos.rb', "db/migrate", :migration_file_name => 'create_alter_egos')
    end
  end
end
class SchizophreniaGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template('create_schizophrenics.rb', "db/migrate", :migration_file_name => 'create_schizophrenics')
    end
  end
end
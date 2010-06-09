namespace :has_alter_ego do
  desc "Dump the objects of MODEL from the database in a YAML file as alter egos"
  task :dump => :environment do
    HasAlterEgo::Dumper.dump
  end
end

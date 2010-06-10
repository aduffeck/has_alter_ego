module HasAlterEgo
  class Dumper
    def self.dump
      raise "You need to pass a MODEL=<model name> argument to rake" if ENV["MODEL"].blank?
      klaas = ENV["MODEL"].constantize

      yml_file = File.join(RAILS_ROOT, "db", "fixtures", "alter_egos", klaas.table_name + ".yml")
      yml = {}
      if File.exists?(yml_file)
        File.open(yml_file) do |yf|
          yml = YAML::load( yf )
        end
      end

      puts yml.inspect
      klaas.all.each do |o|
        key = o[klaas.primary_key]
        yml[key] ||= {}
        o.attributes.keys.each do |a|
          next if a == klaas.primary_key
          yml[key][a] = o[a]
        end
        o.build_alter_ego unless o.alter_ego
        o.alter_ego.state = 'default'
        o.save_without_alter_ego
      end
      File.open(yml_file, File::WRONLY|File::TRUNC|File::CREAT) do |yf|
        yf.write yml.to_yaml
      end
    end
  end
end
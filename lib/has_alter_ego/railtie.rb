module HasAlterEgo
  class Railtie < Rails::Railtie

    rake_tasks do
      load "tasks/has_alter_ego.rake"
    end

  end
end

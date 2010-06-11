require File.join(File.dirname(__FILE__), "has_alter_ego", "alter_ego")

module HasAlterEgo
  module ActiveRecordAdapater
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def has_alter_ego opts = {}
        opts.reverse_merge!({:reserved_space => 1000})

        class_eval do
          has_one :alter_ego, :as => :alter_ego_object
          alias_method :save_without_alter_ego, :save
          alias_method :destroy_without_alter_ego, :destroy
          send :include, InstanceMethods
          reserve_space(opts[:reserved_space])
          parse_yml
        end
      end

      # Reserve the first n IDs for stubbed objects
      def reserve_space space
        return unless self.columns_hash[self.primary_key].klass == Fixnum
        return if self.last and self.last[self.primary_key] >= space

        o = self.new
        o[self.primary_key] = space
        o.save_without_alter_ego
        o.delete
        return
      end

      def parse_yml
        yml = get_yml
        yml.keys.each do |o|
          parse_yml_for o
        end
        yml
      end

      def parse_yml_for primary_key
        yml = get_yml
        db_object = self.find(primary_key) rescue nil
        if db_object
          raise "There is already a #{db_object.class} with id #{db_object.id} in the database." unless db_object.has_alter_ego?
          if db_object.alter_ego.state == 'default'
            yml[primary_key].keys.each do |attr|
              next unless db_object.respond_to?(attr)
              db_object.send(attr+"=", yml[primary_key][attr])
            end
            db_object.on_seed(yml[primary_key])
            db_object.save_without_alter_ego
          end
        else
          # Check for destroyed alter_egos
          alter_ego = AlterEgo.find_by_alter_ego_object_id_and_alter_ego_object_type(primary_key, self.name)
          return if alter_ego.try(:state) == "destroyed"

          db_object = self.new
          db_object[self.primary_key] = primary_key
          yml[primary_key].keys.each do |attr|
            next unless db_object.respond_to?(attr)
            db_object.send(attr+"=" , yml[primary_key][attr])
          end
          db_object.build_alter_ego
          db_object.alter_ego.state = 'default'
          db_object.on_seed(yml[primary_key])
          db_object.save_without_alter_ego
        end
      end

      private

      def get_yml
        filename = File.join(RAILS_ROOT, "db", "fixtures", "alter_egos", self.table_name + ".yml")
        return {} unless File.exists?(filename)
        yml = File.open(filename) do |yf|
          YAML::load( yf )
        end
        yml
      end
    end

    module InstanceMethods
      def has_alter_ego?
        return self.alter_ego.present?
      end

      def alter_ego_state
        self.alter_ego.state if self.alter_ego
      end

      def save perform_validation = true
        if self.alter_ego
          self.alter_ego.state = 'modified'
          self.alter_ego.save
        end
        if ActiveRecord::VERSION::MAJOR == 3 and !perform_validation.is_a?(Hash)
          perform_validation = {:validate => perform_validation}
        end
        save_without_alter_ego perform_validation
      end

      def destroy
        if self.alter_ego
          self.alter_ego.state = 'destroyed'
          self.alter_ego.save
        end
        destroy_without_alter_ego
      end

      def pin!
        self.alter_ego.state = 'pinned'
        self.alter_ego.save
      end

      def reset
        self.alter_ego.state = 'default'
        self.alter_ego.save

        self.class.parse_yml_for self[self.class.primary_key]
        self.reload
      end

      def on_seed attributes
        # Not implemented
      end
    end
  end
end

class ActiveRecord::Base
  include HasAlterEgo::ActiveRecordAdapater
end

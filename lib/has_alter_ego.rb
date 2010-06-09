require File.join(File.dirname(__FILE__), "has_alter_ego", "alter_ego")

module HasAlterEgo
  # Reserve the first n IDs for stubbed objects
  def self.reserve_space klaas, space
    return unless klaas.columns_hash[klaas.primary_key].klass == Fixnum
    return if klaas.last and klaas.last[klaas.primary_key] >= space

    o = klaas.new
    o[klaas.primary_key] = space
    o.save_without_alter_ego
    o.destroy
  end

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
          send :include, InstanceMethods
          HasAlterEgo.reserve_space(self, opts[:reserved_space])
          parse_yml
        end
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
              db_object[attr] = yml[primary_key][attr]
            end
            db_object.save_without_alter_ego
          end
        else
          db_object = self.new
          db_object[self.primary_key] = primary_key
          yml[primary_key].keys.each do |attr|
            db_object[attr] = yml[primary_key][attr]
          end
          db_object.build_alter_ego
          db_object.alter_ego.state = 'default'
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
        save_without_alter_ego perform_validation
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
    end
  end
end

class ActiveRecord::Base
  include HasAlterEgo::ActiveRecordAdapater
end

require File.join(File.dirname(__FILE__), "schizophrenia", "schizophrenic")

module Schizophrenia
  module ActiveRecordAdapater
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def has_schizophrenia opts = {}
        opts.reverse_merge!({:reserved_space => 1000})

        class_eval do
          has_one :schizophrenic, :as => :schizophrenic_object
          alias_method :save_without_schizophrenia, :save
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
        o.save_without_validation
        o.destroy
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
          raise "There is already a #{db_object.class} with id #{db_object.id} in the database." unless db_object.schizophrenic?
          if db_object.schizophrenic.state == 'default'
            yml[primary_key].keys.each do |attr|
              db_object[attr] = yml[primary_key][attr]
            end
            db_object.save_without_schizophrenia
          end
        else
          db_object = self.new
          db_object[self.primary_key] = primary_key
          yml[primary_key].keys.each do |attr|
            db_object[attr] = yml[primary_key][attr]
          end
          db_object.build_schizophrenic
          db_object.schizophrenic.state = 'default'
          db_object.save_without_schizophrenia
        end
      end

      private

      def get_yml
        filename = File.join(RAILS_ROOT, "db", "fixtures", "schizophrenia", self.table_name + ".yml")
        return {} unless File.exists?(filename)
        yml = File.open(filename) do |yf|
          YAML::load( yf )
        end
        yml
      end
    end

    module InstanceMethods
      def schizophrenic?
        return self.schizophrenic.present?
      end

      def schizophrenia_state
        self.schizophrenic.state if self.schizophrenic
      end

      def save perform_validation = true
        if self.schizophrenic
          self.schizophrenic.state = 'modified'
          self.schizophrenic.save
        end
        save_without_schizophrenia perform_validation
      end

      def reset
        self.schizophrenic.state = 'default'
        self.schizophrenic.save

        self.class.parse_yml_for self[self.class.primary_key]
        self.reload
      end
    end
  end
end

class ActiveRecord::Base
  include Schizophrenia::ActiveRecordAdapater
end

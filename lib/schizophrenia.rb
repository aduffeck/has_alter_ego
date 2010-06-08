require File.join(File.dirname(__FILE__), "schizophrenia", "schizophrenic")

module Schizophrenia
  module ActiveRecordAdapater
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def has_schizophrenia options = {}
        options.reverse_merge!(:reserved_space => 1000)

        class_eval do
          has_one :schizophrenic, :as => :schizophrenic_object
          send :include, InstanceMethods
          reserve_space(options[:reserved_space])
          parse_yml_representation
        end
      end

      # Reserve the first n IDs for stubbed objects
      def reserve_space space
        max_id = Car.connection.execute("SELECT id FROM #{Car.name.pluralize.downcase} ORDER BY id DESC LIMIT 1").first["id"].to_i
        return if max_id >= space
        case self.connection.adapter_name
        when "SQLite"
          self.connection.execute("UPDATE SQLITE_SEQUENCE SET seq = #{space} WHERE name = '#{self.name.pluralize.downcase}'")
        when "PostgreSQL"
          self.connection.execute("SELECT setval('#{self.name.pluralize.downcase}', #{space});")
        when "MySQL"
          self.connection.execute("ALTER TABLE #{self.name.pluralize.downcase} AUTO_INCREMENT=#{space}")
        end
      end

      def parse_yml_representation
        yml = File.open( File.join(RAILS_ROOT, "db", "fixtures", "schizophrenia", self.name.pluralize.downcase + ".yml") ) do |yf|
          YAML::load( yf )
        end
        yml
      end
    end

    module InstanceMethods
      def schizophrenic?
        return self.schizophrenic.present?
      end
    end
  end
end

class ActiveRecord::Base
  include Schizophrenia::ActiveRecordAdapater
end

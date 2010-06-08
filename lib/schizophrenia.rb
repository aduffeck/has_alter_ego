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
          send :include, InstanceMethods
          reserve_space(opts[:reserved_space])
          parse_yml_representation
        end
      end

      # Reserve the first n IDs for stubbed objects
      def reserve_space space
        max_id = self.last.id
        return if max_id >= space

        o = self.new
        o.id = space
        o.save_without_validation
        o.destroy
        return
      end

      def parse_yml_representation
        filename = File.join(RAILS_ROOT, "db", "fixtures", "schizophrenia", self.name.pluralize.downcase + ".yml")
        return unless File.exists?(filename)
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
    end
  end
end

class ActiveRecord::Base
  include Schizophrenia::ActiveRecordAdapater
end

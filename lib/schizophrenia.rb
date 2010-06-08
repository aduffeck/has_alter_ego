module Schizophrenia
  module ActiveRecordAdapater
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def has_schizophrenia options = {}
        class_eval do

          send :include, InstanceMethods
          parse_yml_representation
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
    end
  end
end

class ActiveRecord::Base
  include Schizophrenia::ActiveRecordAdapater
end

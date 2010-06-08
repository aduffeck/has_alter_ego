require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'test/unit'
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

require File.dirname(__FILE__) + '/../lib/schizophrenia'
RAILS_ROOT = File.dirname(__FILE__)

silence_stream(STDOUT) do
  ActiveRecord::Schema.define do
    create_table :uuids do |t|
      t.integer :schizophrenic_object_id
      t.string :schizophrenic_object_type, :limit => 40
      t.string :state
    end

    create_table :cars

    create_table :bikes
  end
end
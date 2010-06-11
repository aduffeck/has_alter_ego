require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'test/unit'
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

require File.dirname(__FILE__) + '/../lib/has_alter_ego'
RAILS_ROOT = File.dirname(__FILE__)

silence_stream(STDOUT) do
  ActiveRecord::Schema.define do
    create_table :alter_egos do |t|
      t.string :alter_ego_object_id
      t.string :alter_ego_object_type, :limit => 40
      t.string :state
    end

    create_table :cars do |t|
      t.string :brand
      t.string :model
      t.integer :tires_count
    end

    create_table :bikes
    create_table :scooters

    create_table :tires do |t|
      t.integer :car_id
    end

    create_table :drinks, :id => false do |t|
      t.string :name
      t.string :color
    end

    create_table :sellers do |t|
      t.string :name
    end
    create_table :cars_sellers, :id => false do |t|
      t.integer :car_id
      t.integer :seller_id
    end

  end
end
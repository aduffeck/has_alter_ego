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

    create_table :lights do |t|
      t.string :color
      t.boolean :active
      t.integer :bike_id
    end

    create_table :tires do |t|
      t.integer :car_id
    end

    create_table :drinks do |t|
      t.string :name
      t.string :color
    end

    create_table :creators do |t|
      t.string :name
      t.integer :drink_id
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


class Seller < ActiveRecord::Base
  has_and_belongs_to_many :cars
  has_alter_ego
end

class Car < ActiveRecord::Base
  has_many :tires
  has_and_belongs_to_many :sellers
  has_alter_ego
  attr_accessor :tires_count

  def on_seed attributes
    self[:tires_count] = attributes["custom_data"]["tires"] if attributes["custom_data"]
  end
end

class Bike < ActiveRecord::Base
  has_many :lights
end

class Scooter < ActiveRecord::Base
end

class Light < ActiveRecord::Base
end

class Tire < ActiveRecord::Base
end

class Drink < ActiveRecord::Base
  has_one :creator
  has_alter_ego
end

class Creator < ActiveRecord::Base
  belongs_to :drink
  has_alter_ego
end

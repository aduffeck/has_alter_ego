require 'test_helper'

class HasAlterEgoTest < Test::Unit::TestCase
  def test_space_gets_reserved
    c = Car.create
    assert_equal 1001, c.id

    assert_equal 1, Scooter.create.id
    Scooter.has_alter_ego :reserved_space => 500
    assert_equal 501, Scooter.create.id
  end

  def test_has_alter_ego?
    assert Car.find(1).alter_ego
    assert !Car.new.has_alter_ego?
  end

  def test_create_objects_from_yml
    assert_equal 6, Car.count
    c1 = Car.find(1)
    assert_equal "Lotus", c1.brand
    assert_equal "Elise", c1.model
    assert c1.has_alter_ego?
  end

  def test_exception_is_raised_if_id_is_already_in_use
    bike = Bike.create
    assert_raise RuntimeError do
      Bike.has_alter_ego
    end
  end

  def test_object_attributes_are_updated_if_not_modified
    c = Car.find(1)
    assert_equal "Lotus", c.brand
    assert_equal "default", c.alter_ego_state

    c.brand = "Toyota"
    c.save_without_alter_ego
    c.reload
    assert_equal "Toyota", c.brand
    assert_equal "default", c.alter_ego_state

    Car.parse_yml
    c.reload
    assert_equal "Lotus", c.brand
  end

  def test_object_attributes_are_not_updated_if_pinned
    c = Car.find(2)
    c.reset
    assert_equal "Porsche", c.brand

    c.brand = "VW"
    c.save_without_alter_ego
    c.pin!
    c.reload
    assert_equal "VW", c.brand
    assert_equal "pinned", c.alter_ego_state

    Car.parse_yml
    c.reload
    assert_equal "VW", c.brand
  end

  def test_object_attributes_are_not_updated_if_modified
    c = Car.find(2)
    assert_equal "Porsche", c.brand

    c.brand = "VW"
    c.save
    c.reload
    assert_equal "VW", c.brand
    assert_equal "modified", c.alter_ego_state

    Car.parse_yml
    c.reload
    assert_equal "VW", c.brand
  end

  def test_reset
    c = Car.find(3)
    assert_equal "Ferrari", c.brand
    assert_equal "default", c.alter_ego_state

    c.brand = "Fiat"
    c.save
    c.reload

    assert_equal "Fiat", c.brand
    assert_equal "modified", c.alter_ego_state
    c.reset
    c.reload

    assert_equal "Ferrari", c.brand
    assert_equal "default", c.alter_ego_state
  end

  def test_associations_do_not_change_state
    c = Car.find(4)
    assert_equal "default", c.alter_ego_state
    assert_equal 0, c.tires.size

    4.times do
      c.tires << Tire.new
    end
    c.reload
    assert_equal "default", c.alter_ego_state
    assert_equal 4, c.tires.size
  end

  def test_different_primary_key
    assert_equal 2, Drink.all.size
    assert_equal "none", Drink.find("water").color

    water = Drink.find("water")
    assert water.has_alter_ego?
    assert_equal "default", water.alter_ego_state

    water.color = "blue"
    water.save
    water.reload
    assert_equal "blue", water.color
    assert_equal "modified", water.alter_ego_state

    water.reset
    water.reload
    assert_equal "none", water.color
    assert_equal "default", water.alter_ego_state

    orangejuice = Drink.new
    orangejuice.name = "orangejuice"
    orangejuice.color = "yellow"
    orangejuice.save
    assert !orangejuice.has_alter_ego?
  end

  def test_destroyed_object_leaves_destroyed_alter_ego
    c = Car.find(6)
    alter_ego = c.alter_ego
    assert_equal "default", alter_ego.state

    c.destroy
    alter_ego.reload
    assert_equal "destroyed", alter_ego.state
  end

  def test_destroyed_objects_do_not_return
    assert Car.find_by_id(5)
    Car.find_by_id(5).destroy
    assert !Car.find_by_id(5)

    Car.parse_yml
    assert !Car.find_by_id(5)
  end

  def test_on_seed
    assert_nil Car.find(1).tires_count
    assert_equal 4, Car.find(4)[:tires_count]
  end

  def test_habtm
    assert_equal [1,2], Car.find(1).seller_ids
    assert_equal 2, Car.find(1).sellers.size

    c = Car.find(1)
    c.sellers = [Seller.first]
    c.reload

    assert_equal [Seller.first], c.sellers
    assert_equal [Seller.first.id], c.seller_ids

    c.reset
    c.reload

    assert_equal [1,2], c.seller_ids
  end

  def test_smart_habtm
    Car.destroy_all
    AlterEgo.find_all_by_alter_ego_object_type("Car").map(&:destroy)
    Car.class_eval do
      def self.get_yml
        return {1 => {
                  "brand" => "Lotus",
                  "model" => "Elise",
                  "sellers_by_name" => ["Harald", "Hugo"]}}
      end
    end
    Car.parse_yml
    assert_equal 1, Car.count
    assert_equal 2, Car.first.sellers.size
    assert_equal [2,3].sort, Car.first.seller_ids.sort
  end

  def test_smart_has_many
    Light.create(:color => "blue", :active => true)
    Light.create(:color => "yellow", :active => true)
    Light.create(:color => "red", :active => true)
    Light.create(:color => "green", :active => false)
    Bike.destroy_all
    Bike.class_eval do
      def self.get_yml
        return {1 => {
                  "lights_by_color_and_active" => [["blue", "yellow", "green"], true]}}
      end
    end
    Bike.parse_yml
    assert_equal 1, Bike.count
    assert_equal 2, Bike.first.lights.size
    assert_equal Light.find_all_by_color(["blue", "yellow"]), Bike.first.lights
  end

  def test_smart_has_one
    Creator.create(:name => "Martin")
    Creator.create(:name => "Mike")
    Drink.destroy_all
    Drink.class_eval do
      def self.get_yml
        return {1 => {
                  "creator_by_name" => ["Mike"]}}
      end
    end
    Drink.parse_yml
    assert_equal 1, Drink.count
    assert_equal Creator.find_by_name("Mike"), Drink.first.creator
  end

  def test_smart_belongs_to

    Creator.class_eval do
      def self.get_yml
        return {1 => {
                  "name" => "Bernd",
                  "drink_by_name" => "water"}}
      end
    end
    Creator.parse_yml
    c = Creator.find_by_name "Bernd"
    assert_equal Drink.find_by_name("water"), c.drink
  end
end

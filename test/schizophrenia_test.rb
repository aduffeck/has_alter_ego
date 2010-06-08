require 'test_helper'

class Car < ActiveRecord::Base
  has_schizophrenia
end

class Bike < ActiveRecord::Base
end

class Scooter < ActiveRecord::Base
end

class SchizophreniaTest < Test::Unit::TestCase
  def test_space_gets_reserved
    c = Car.create
    assert_equal 1001, c.id

    assert_equal 1, Scooter.create.id
    Scooter.has_schizophrenia :reserved_space => 500
    assert_equal 501, Scooter.create.id
  end

  def test_schizophrenic?
    assert Car.find(1).schizophrenic
    assert !Car.new.schizophrenic?
  end

  def test_create_objects_from_yml
    assert_equal 2, Car.count
    c1 = Car.find(1)
    assert_equal "Lotus", c1.brand
    assert_equal "Elise", c1.model
    assert c1.schizophrenic?
  end

  def test_exception_is_raised_if_id_is_already_in_use
    bike = Bike.create
    assert_raise RuntimeError do
      Bike.has_schizophrenia
    end
  end

  def test_object_attributes_are_updated_if_not_modified
    c = Car.find(1)
    assert_equal c.brand, "Lotus"

    c.update_attribute(:brand, "Toyota")
    c.save_without_schizophrenia
    c.reload
    assert_equal c.brand, "Toyota"

    Car.parse_yml_representation
    c.reload
    assert_equal c.brand, "Lotus"
  end
end

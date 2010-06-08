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
    assert_equal 3, Car.count
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
    assert_equal "Lotus", c.brand
    assert_equal "default", c.schizophrenia_state

    c.brand = "Toyota"
    c.save_without_schizophrenia
    c.reload
    assert_equal "Toyota", c.brand
    assert_equal "default", c.schizophrenia_state

    Car.parse_yml
    c.reload
    assert_equal "Lotus", c.brand
  end

  def test_object_attributes_are_not_updated_if_modified
    c = Car.find(2)
    assert_equal "Porsche", c.brand

    c.brand = "VW"
    c.save
    c.reload
    assert_equal "VW", c.brand
    assert_equal "modified", c.schizophrenia_state

    Car.parse_yml
    c.reload
    assert_equal "VW", c.brand
  end

  def test_reset
    c = Car.find(3)
    assert_equal "Ferrari", c.brand

    c.brand = "Fiat"
    c.save
    c.reload

    assert_equal "Fiat", c.brand
    c.reset
    c.reload

    assert_equal "Ferrari", c.brand
  end
end

require 'test_helper'

class Car < ActiveRecord::Base
  has_schizophrenia
end

class Bike < ActiveRecord::Base
end

class SchizophreniaTest < Test::Unit::TestCase
  def test_space_gets_reserved
    c = Car.create
    assert_equal 1001, c.id

    assert_equal 1, Bike.create.id
    Bike.has_schizophrenia :reserved_space => 500
    assert_equal 501, Bike.create.id
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
end

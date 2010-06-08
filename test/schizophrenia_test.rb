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
end

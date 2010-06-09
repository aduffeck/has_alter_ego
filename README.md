# has_alter_ego

has_alter_ego makes it possible to keep seed and live data transparently in parallel. In contrast to other seed
data approaches has_alter_ego synchronizes the seed definitions with your database objects automagically unless you've
overridden it in the database.

# Installation

## Rails 2.3.x
### As a plugin
    script/plugin install git://github.com/aduffeck/has_alter_ego.git
    script/generate has_alter_ego
    rake db:migrate

### As a gem
Add the following line to your config/environment.rb file:
    config.gem "has_alter_ego"
Then
    gem install has_alter_ego
    script/generate has_alter_ego
    rake db:migrate

# Usage

The seed data is defined in YAML files called after the model's table. The files are expected in db/fixtures/alter_egos.

Say you have a Model Car. has_alter_ego is enabled with the has_alter_ego method:

    create_table :cars do |t|
      t.string :brand
      t.string :model
    end


    class Car < ActiveRecord::Base
      has_alter_ego
    end

You would then create a file db/fixtures/has_alter_ego/cars.yml with the seed data:

    1:
      brand: Lotus
      model: Elise

    2:
      brand: Porsche
      model: 911

    3:
      brand: Ferrari
      model: F50

    4:
      brand: Corvette
      model: C5

and you'd automagically have those objects available in your database.

    Car.find(1)
    => #<Car id: 1, brand: "Lotus", model: "Elise">

Whenever the seed definition changes the objects in the database inherit the changes unless they have been overridden.
You can check if an object was created from seed definition with *has_alter_ego?*:

    @car = Car.find(1)
    @car.has_alter_ego?
    => true

    Car.new.has_alter_ego?
    => false

The method *alter_ego_state* tells whether an object has been overridden. "modified" objects will no longer inherit
changes to the seed data.

    @car.alter_ego_state
    => "default"

    @car.update_attribute(:model, "foo")
    => true
    @car
    => #<Car id: 1, brand: "Lotus", model: "foo">
    @car.alter_ego_state
    => "modified"

If you don't want to inherit changes for an object without actually modifying it you can use *pin!*:

    @car.pin!
    => true
    @car.alter_ego_state
    => "pinned"


*reset* reverts the changes in the database and activates the synchronization again:
    @car.reset
    => #<Car id: 1, brand: "Lotus", model: "Elise">
    @car.alter_ego_state
    => "default"


Copyright (c) 2010 André Duffeck, released under the MIT license

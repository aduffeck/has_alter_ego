# has_alter_ego

has_alter_ego makes it possible to keep seed and live data transparently in parallel. In contrast to other seed
data approaches has_alter_ego synchronizes the seed definitions with your database objects automagically unless you've
overridden it in the database.

# Installation

## Rails 2.3.x
### As a gem
Add the following line to your **config/environment.rb** file:
    config.gem "has_alter_ego"
Then
    gem install has_alter_ego
    script/generate has_alter_ego
    rake db:migrate

### As a plugin
    script/plugin install git://github.com/aduffeck/has_alter_ego.git
    script/generate has_alter_ego
    rake db:migrate


## Rails 3
### As a gem
Add the following line to your **Gemfile** file:
    gem "has_alter_ego"
Then
    bundle install
    rails generate has_alter_ego
    rake db:migrate

### As a plugin
    rails plugin install git://github.com/aduffeck/has_alter_ego.git
    rails generate has_alter_ego
    rake db:migrate


# Usage
## General
The seed data is defined in YAML files called after the model's table. The files are expected in **db/fixtures/alter_egos**.

Say you have a Model *Car*. has_alter_ego is enabled with the *has_alter_ego* method:

    create_table :cars do |t|
      t.string :brand
      t.string :model
    end


    class Car < ActiveRecord::Base
      has_alter_ego
    end

You could then create a file **db/fixtures/alter_egos/cars.yml** with the seed data:

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
When a seed object was destroyed in the database it will not be added again.

**Note:** If the table has a numeric primary key has_alter_ego reserves the first n IDs for seed objects (default=1000),
so the next non-seed object will get the ID 1001.
The number of reserved objects can be set with the optional *:reserved_space* parameter, e.g.

    has_alter_ego :reserved_space => 5000

You always have to make sure that no seed IDs clash with IDs in the database.


## Advanced stuff
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

# Custom logic on seed

has_alter_ego provides a hook for adding custom logic when an object is created or updated from the seed definitions.
Just add a method *on_seed(attributes)* to your Model and you'll have access to all the seed attributes.
**Note:** You should not call save from within the hook or the objects will be marked as modified.

Example:
    class Car < ActiveRecord::Base
      has_alter_ego

      def on_seed(attributes)
        self.price = attributes["price_without_vat"] * VAT_FACTOR
      end
    end

# Generating seed data from the database

has_alter_ego has a rake task for dumping the current database content into a seed file. It is called like this:

    rake has_alter_ego::dump MODEL=Car

That will fill **db/fixtures/alter_egos/cars.yml** with the database objects. 

Copyright (c) 2010 André Duffeck, released under the MIT license

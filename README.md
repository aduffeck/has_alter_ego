# schizophrenia

schizophrenia makes it possible to keep seed and and live data transparently in parallel. In contrast to other seed data
approaches schizophrenia keeps your database and the seed definition in sync unless you've overridden it in the database.

# Installation

## Rails 2.3.x
### As a plugin
    script/plugin install git://github.com/aduffeck/schizophrenia.git
    script/generate schizophrenia
    rake db:migrate

# Usage

The seed data is defined in YAML files called after the model's table. The files are expected in db/fixtures/schizophrenia.

Say you have a Model Car. schizophrenia is enabled with the has_schizophrenia method:

    create_table :cars do |t|
      t.string :brand
      t.string :model
    end


    class Car < ActiveRecord::Base
      has_schizophrenia
    end

You would then create a file db/fixtures/schizophrenia/cars.yml with the data:

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
You can check if an object was created by the seed definition with schizophrenic?:

    @car = Car.find(1)
    @car.schizophrenic?
    => true

    Car.new.schizophrenic?
    => false

    # schizophrenia_state tells whether an object has been overridden
    # "modified" objects will no longer inherit changes to the seed data
    @car.schizophrenia_state
    => "default"

    @car.update_attribute(:model, "foo")
    => true
    @car
    => #<Car id: 1, brand: "Lotus", model: "foo">
    @car.schizophrenia_state
    => "modified"

    # reset reverts the local changes and activates the synchronization again
    @car.reset
    => #<Car id: 1, brand: "Lotus", model: "Elise">
    @car.schizophrenia_state
    => "default"


Copyright (c) 2010 Andre Duffeck, released under the MIT license

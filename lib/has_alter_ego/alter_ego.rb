class AlterEgo < ActiveRecord::Base
  belongs_to :alter_ego_object, :polymorphic => true
end
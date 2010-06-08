class Schizophrenic < ActiveRecord::Base
  belongs_to :schizophrenic_object, :polymorphic => true
end
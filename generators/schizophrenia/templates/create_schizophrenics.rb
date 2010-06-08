class CreateSchizophrenics < ActiveRecord::Migration
  def self.up
    create_table :schizophrenics do |t|
      t.string :schizophrenic_object_id
      t.string :schizophrenic_object_type, :limit => 40
      t.string :state
    end
    add_index :uuids, [:schizophrenic_object_id, :schizophrenic_object_type]
  end

  def self.down
    drop_table :schizophrenics
  end
end
class CreateAlterEgos < ActiveRecord::Migration
  def self.up
    create_table :alter_egos do |t|
      t.integer :alter_ego_object_id
      t.string :alter_ego_object_type, :limit => 40
      t.string :state
    end
    add_index :alter_egos, [:alter_ego_object_id, :alter_ego_object_type]
  end

  def self.down
    drop_table :alter_egos
  end
end

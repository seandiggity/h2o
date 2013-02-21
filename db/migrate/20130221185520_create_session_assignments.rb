class CreateSessionAssignments < ActiveRecord::Migration
  def self.up
    create_table :session_assignments do |t|
      t.integer :playlist_id, :nil => false
      t.integer :session_number, :nil => false
      t.integer :playlist_item_id, :nil => false
      t.timestamps
    end
  end

  def self.down
    drop_table :session_assignments
  end
end

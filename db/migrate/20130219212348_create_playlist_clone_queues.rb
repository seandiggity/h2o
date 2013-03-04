class CreatePlaylistCloneQueues < ActiveRecord::Migration
  def self.up
    create_table :playlist_clone_queues do |t|
      t.integer :playlist_id, :nil => false
      t.integer :user_id, :nil => false
      t.boolean :running, :nil => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :playlist_clone_queues
  end
end

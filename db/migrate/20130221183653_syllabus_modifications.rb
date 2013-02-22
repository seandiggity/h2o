class SyllabusModifications < ActiveRecord::Migration
  def self.up
    add_column :playlists, :class_start_date, :date
    add_column :playlists, :class_end_date, :date
    add_column :playlists, :number_of_sessions, :integer, :nil => false, :default => 0
    add_column :playlists, :session_length, :integer, :nil => false, :default => 0
    add_column :item_defaults, :word_count, :integer, :nil => false, :default => 0
    add_column :medias, :effective_word_count, :integer, :nil => false, :default => 0
    add_column :journal_articles, :word_count, :integer, :nil => false, :default => 0
    add_column :text_blocks, :word_count, :integer, :nil => false, :default => 0
    add_column :cases, :word_count, :integer, :nil => false, :default => 0

    conxn = ActiveRecord::Base.connection
    [JournalArticle, TextBlock, Case].each do |klass|
      klass.find_in_batches do |items|
        items.each do |item|
          wc = item.get_word_count
          conxn.execute("UPDATE #{klass.to_s.tableize} SET word_count = #{wc} WHERE id = #{item.id}")
        end
      end
    end
  end

  def self.down
    remove_column :playlists, :class_start_date
    remove_column :playlists, :class_end_date
    remove_column :playlists, :number_of_sessions
    remove_column :playlists, :session_length
    remove_column :item_defaults, :word_count
    remove_column :medias, :effective_word_count
    remove_column :journal_articles, :word_count
    remove_column :text_blocks, :word_count
    remove_column :cases, :word_count
  end
end

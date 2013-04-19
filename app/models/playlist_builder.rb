[Playlist, ItemCollage, ItemTextBlock, Collage, TextBlock, Media, Case, Default, Question, 
 QuestionInstance, RotisserieDiscussion, Collage::Version, PlaylistItem, ItemCase, ItemDefault,
 ItemMedia, ItemPlaylist, ItemQuestion, ItemQuestionInstance, ItemRotisserieDiscussion].each do |klass|
  klass.class_eval do 
    def self.insert_column_names
      self.columns.reject{|col| col.name == "id"}.map(&:name)
    end

    def self.insert_value_names(options = {})
      overrides = options[:overrides]
      table_name = options[:table_name] || self.table_name
      results = self.insert_column_names.map{|name| "#{table_name}.#{name}"}
      results[self.insert_column_names.index("updated_at")] = "\'#{Time.now.to_formatted_s(:db)}\' AS updated_at"
      results[self.insert_column_names.index("created_at")] = "\'#{Time.now.to_formatted_s(:db)}\' AS created_at"
      if overrides
        overrides.each_pair do |key, value|
          results[self.insert_column_names.index(key.to_s)] = ActiveRecord::Base.connection.quote(value)
        end
      end
      results
    end 
                                                                                                            
    
  end   
end   

Array.class_eval do
  def to_insert_value_s
    res = self.map{|value| ActiveRecord::Base.connection.quote(value)}
    res = "(#{res.join(", ")})"
    res
  end
end

class PlaylistBuilder
  
    
  def self.build_insert_sql(klass, values_sql)
    res = "INSERT INTO \"#{klass.table_name}\" (#{klass.insert_column_names.join(", ")}) VALUES "    
    res += values_sql
    res += " RETURNING *; "
    res    
  end
  
  def self.build_insert_values_sql(select_statements)
    sql = select_statements.inject([]) do |arr, select_statement|
      arr << PlaylistBuilder.get_values(select_statement)
    end.join(", ")
  end                                
  
  def self.get_values(sql)
    rows = ActiveRecord::Base.connection.select_rows(sql)
    rows = rows.inject([]){|arr, r| arr << r.to_insert_value_s}.join(", ")
    rows
  end  
  
  def self.execute!(sql)
    results = ActiveRecord::Base.connection.execute(sql)
    results = results.entries.map{|entry| entry['id']}
    results
  end
end
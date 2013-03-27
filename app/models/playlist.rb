require 'tagging_extensions'
require 'redcloth_extensions'
require 'ancestry_extensions'

class Playlist < ActiveRecord::Base
  extend RedclothExtensions::ClassMethods
  extend TaggingExtensions::ClassMethods

  include PlaylistableExtensions
  include AuthUtilities

  #no sql injection here.
  acts_as_list :scope => 'ancestry = #{self.connection.quote(self.ancestry)}'
  acts_as_authorization_object
  acts_as_taggable_on :tags

  has_ancestry :orphan_strategy => :restrict

  has_many :playlist_items, :order => "playlist_items.position", :dependent => :destroy
  has_many :roles, :as => :authorizable, :dependent => :destroy
  has_and_belongs_to_many :user_collections   # dependent => destroy

  validates_presence_of :name
  validates_length_of :name, :in => 1..250

  before_destroy :collapse_children
  named_scope :public, :conditions => {:public => true, :active => true}

  searchable(:include => [:tags]) do
    text :display_name
    string :display_name, :stored => true
    string :id, :stored => true
    text :description
    text :name
    string :tag_list, :stored => true, :multiple => true
    string :author 

    boolean :public
    boolean :active

    time :created_at
  end

  def display_name
    owners = self.accepted_roles.find_by_name('owner')
    "\"#{self.name}\",  #{self.created_at.to_s(:simpledatetime)} #{(owners.blank?) ? '' : ' by ' + owners.users.collect{|u| u.login}.join(',')}"
  end
  alias :to_s :display_name

  def bookmark_name
    self.name
  end

  def parents
    ItemPlaylist.find_all_by_actual_object_id(self.id).collect { |p| p.playlist_item.playlist_id }.uniq
  end

  def self.cache_options
    options = []
    ['true', 'false'].each do |ann|
      [11, 14, 16].each do |size|
        ['true', 'false'].each do |text|
          ['serif', 'sans-serif'].each do |type|
            options << "ann=#{ann}&size=#{size}&text=#{text}&type=#{type}"
          end
        end
      end
    end
    options
  end

  def relation_ids
    r = self.parents
    i = 0
    while i < r.size
      Playlist.find(r[i]).parents.each do |a|
        next if r.include?(a) 
        r.push(a)
      end
      i+=1
    end
    r
  end

  def collage_word_count
    shown_word_count = 0
    total_word_count = 0
    self.playlist_items.each do |pi|
      if pi.resource_item_type == 'ItemCollage' && pi.resource_item.actual_object
        shown_word_count += pi.resource_item.actual_object.words_shown.to_i
        total_word_count += (pi.resource_item.actual_object.word_count.to_i-1) 
      elsif pi.resource_item_type == 'ItemPlaylist' && pi.resource_item.actual_object
        res = pi.resource_item.actual_object.collage_word_count
        shown_word_count += res[0]
        total_word_count += res[1]
      end
    end
    [shown_word_count, total_word_count]
  end

  def contains_item?(item)
    actual_objects = self.playlist_items.inject([]) do |arr, pi| 
      arr << pi.resource_item.actual_object if pi.resource_item && pi.resource_item.actual_object; arr
    end
    actual_objects.include?(item)
  end
  
  def push!(options = {})
    if options[:recipient]
      push_to_recipient!(options[:recipient])
    elsif options[:recipients]
      options[:recipients].each do |r|
        push_to_recipient!(r)
      end
    else
      false
    end
  end           
  
  private
  
  def push_to_recipient!(recipient)
     playlist = self
     indent = "\t"

     cloned_playlist = playlist.clone    
     cloned_playlist.save!
     cloned_playlist.accepts_role!(:owner, recipient)
     cloned_playlist.accepts_role!(:creator, recipient)
     Rails.cache.delete("user-playlists-#{recipient.id}")
     cloned_playlist.tag_list = playlist.tag_list

     playlist.playlist_items.each do |pi|
       cloned_playlist_item = pi.clone 
       cloned_playlist_item.save!
       cloned_playlist_item.accepts_role!(:owner, recipient)
       cloned_resource_item = pi.resource_item.clone
       cloned_resource_item.save!
       cloned_resource_item.accepts_role!(:owner, recipient)
       if pi.resource_item.actual_object
         if pi.resource_item_type == 'ItemPlaylist'
           puts "#{indent}cloning playlist: #{pi.resource_item.actual_object}"
           cloned_object = deep_clone(pi.resource_item.actual_object, recipients, "#{indent}\t")
         else
           puts "#{indent}cloning item: #{pi.resource_item.actual_object}"
           cloned_object = pi.resource_item.actual_object.clone
           cloned_object.save!
           cloned_object.accepts_role!(:owner, recipient)
           cloned_object.accepts_role!(:creator, recipient)
           cloned_object.tag_list = pi.resource_item.actual_object.tag_list
           cloned_object.save
           if pi.resource_item_type == 'ItemCollage'
             pi.resource_item.actual_object.annotations.each do |annotation|
             cloned_annotation = annotation.clone
             cloned_annotation.collage_id = cloned_object.id
             cloned_annotation.save
             #cloned_annotation.tag_list = annotation.tag_list
             #Assigning tag_list doesn't work for annotations
             #So, work directly with taggings array of objects
             annotation.taggings.each do |tagging|
               cloned_tagging = tagging.clone
               cloned_tagging.update_attribute(:taggable_id, cloned_annotation.id)
             end
           end
           puts "#{indent}*cloned annotations"
          end
        end
        cloned_resource_item.actual_object_id = cloned_object.id
        cloned_resource_item.url = cloned_resource_item.url.gsub(/[0-9]+$/, cloned_object.id.to_s)
      end
      cloned_resource_item.save
      cloned_playlist_item.position = pi.position
      cloned_playlist_item.resource_item_id = cloned_resource_item.id
      cloned_playlist_item.playlist_id = cloned_playlist.id
      cloned_playlist_item.save
    end

    cloned_playlist.save

    return cloned_playlist
    
  end
end

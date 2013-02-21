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
  has_many :session_assignments

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

  def author
    owner = self.accepted_roles.find_by_name('owner')
    owner.nil? ? nil : owner.user.login.downcase
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

  def all_playlist_items
    b = []
    self.playlist_items.each do |pi|
      b << pi
      if pi.resource_item_type == 'ItemPlaylist'
        b << pi.resource_item.actual_object.all_playlist_items
      end
    end
    return b.flatten
  end

  def syllabus_split
    self.all_playlist_items

    total_word_count = p.all_playlist_items.inject(0) { |sum, pi| sum += pi.word_count }
    avg_words_per_session = total_word_count / self.number_of_sessions

    SessionAssignment.destroy(self.session_assignments)    
    sessions = [[]]
    session = 0
    unadded_sessions = self.all_playlist_items
    playlist_no_words = []
    while unadded_sessions.any?
    Rails.logger.warn "stephie: session is: #{session.inspect}"
      playlist_item = unadded_sessions.shift
      if playlist_item.resource_item_type == "ItemPlaylist"
        playlist_no_words << playlist_item
        next
      end
      current_session_word_count = sessions[session].inject(0) { |sum, pi| sum += pi.word_count }
      session_with_item_word_count = current_session_word_count + playlist_item.word_count
      if session_with_item_word_count > avg_words_per_session
        if (session_with_item_word_count - avg_words_per_session).abs > (current_session_word_count - avg_words_per_session).abs
          session += 1
          sessions[session] ||= []
        end
      end
      if playlist_no_words.any?
        playlist_no_words.each do |playlist|
          sessions[session] << playlist
        end
        playlist_no_words = []
      end
      sessions[session] << playlist_item
    end

    sessions.each_with_index do |s, i|
      s.each do |playlist_item|
        SessionAssignment.create(:playlist_id => self.id, 
                                 :session_number => i + 1,
                                 :playlist_item_id => playlist_item.id)
      end
    end

    # average words per session is total_word_count / # sessions
    
    return sessions
  end
end

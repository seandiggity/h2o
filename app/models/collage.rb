require 'tagging_extensions'
require 'redcloth_extensions'
require 'playlistable_extensions'
require 'ancestry_extensions'

class Collage < ActiveRecord::Base
  extend RedclothExtensions::ClassMethods
  extend TaggingExtensions::ClassMethods
  extend HeatmapExtensions::ClassMethods
  
  include H2oModelExtensions
  include PlaylistableExtensions
  include AncestryExtensions::InstanceMethods
  include AuthUtilities
  include MetadataExtensions
  include TaggingExtensions::InstanceMethods
  include HeatmapExtensions::InstanceMethods

  acts_as_taggable_on :tags
  acts_as_authorization_object

  def self.annotatable_classes
    Dir.glob(RAILS_ROOT + '/app/models/*.rb').each do |file| 
      model_name = Pathname(file).basename.to_s
      model_name = model_name[0..(model_name.length - 4)]
      model_name.camelize.constantize
    end
    # Responds to the annotatable class method with true.
    Object.subclasses_of(ActiveRecord::Base).find_all{|m| m.respond_to?(:annotatable) && m.send(:annotatable)}
  end

  def self.annotatable_classes_select_options
    self.annotatable_classes.collect{|c| [c.model_name]}
  end

  acts_as_voteable

  before_destroy :collapse_children
  has_ancestry :orphan_strategy => :restrict 

  belongs_to :annotatable, :polymorphic => true
  has_many :annotations, :order => 'created_at', :dependent => :destroy
  has_and_belongs_to_many :user_collections   # dependent => destroy
  has_many :defects, :as => :reportable
  has_many :color_mappings

  has_many :collage_links, :foreign_key => "host_collage_id"
  has_many :parent_collage_links, :class_name =>  "CollageLink", :foreign_key => "linked_collage_id"
  # Create the content we're going to annotate. This is a might bit inefficient, mainly because
  # we're doing a heavy bit of parsing on each attempted save. It is probably better than allowing
  # the creation of a contentless collage, though.
  before_validation_on_create :prepare_content

  validates_presence_of :annotatable_type, :annotatable_id
  validates_length_of :description, :in => 1..(5.kilobytes), :allow_blank => true

  # TODO: Figure out why tags & annotations breaks in searchable
  searchable(:include => [:tags]) do #, :annotations => {:layers => true}]) do
    text :display_name, :stored => true, :boost => 3.0
    string :display_name, :stored => true
    string :id, :stored => true
    text :description, :boost => 2.0
    text :indexable_content
    boolean :active
    boolean :public
    time :created_at
    string :tag_list, :stored => true, :multiple => true
    string :author

    string :annotatable #, :stored => true
    string :annotations, :multiple => true
    string :layer_list, :multiple => true
  end
  
  def fork_it(new_user)
    collage_copy = self.clone
    collage_copy.name = "#{self.name} copy"
    collage_copy.created_at = Time.now
    collage_copy.parent = self
    collage_copy.accepts_role!(:owner, new_user)
    collage_copy.accepts_role!(:creator, new_user)
    self.creators.each do|c|
      collage_copy.accepts_role!(:original_creator,c)
    end
    self.annotations.each do |annotation|
      new_annotation = annotation.clone
      new_annotation.collage = collage_copy
      #copy tags
      new_annotation.layer_list = annotation.layer_list
      new_annotation.accepts_role!(:creator, new_user)
      new_annotation.accepts_role!(:owner, new_user)
      new_annotation.parent = annotation
      annotation.creators.each do|c|
        new_annotation.accepts_role!(:original_creator, c)
      end
      new_annotation.save
    end
    self.color_mappings.each do |color_mapping|
      color_mapping = color_mapping.clone
      color_mapping.collage_id = collage_copy.id
      color_mapping.save
    end
    collage_copy
  end

  def can_edit?
    return self.owner? || self.admin? || current_user.has_role?(:collages_admin) || current_user.has_role?(:superadmin)
  end

  def display_name
    "#{self.name}, #{self.created_at.to_s(:simpledatetime)}#{(self.creators.blank?) ? '' : ' by ' + self.creators.collect{|u| u.login}.join(',')}"
  end

  def layers
    self.annotations.collect{|a| a.layers}.flatten.uniq
  end

  def layer_list
    self.layers.map(&:name)
  end

  def layer_report
    layers = {}
    self.annotations.each do |ann|
      ann.layers.each do |l|
        if layers[l.id].blank?
          layers[l.id] = {:count => 0, :name => l.name, :annotation_count => 0}
        end
        layers[l.id][:count] = layers[l.id][:count].to_i + ann.word_count
        layers[l.id][:annotation_count] = layers[l.id][:annotation_count].to_i + 1
      end
    end
    return layers
  end

  def editable_content
    doc = Nokogiri::HTML.parse(self.content)

    # Footnote markup
    doc.css("a").each do |li|
      if li['href'] =~ /^#/
        li['class'] = 'footnote'
      end
    end

    # data-id markup
    x = 1
    doc.xpath('//tt').each do |node|
      node['data-id'] = x.to_s
      x+=1
    end

    count = 1
    doc.xpath('//p | //center').each do |node|
      tt_size = node.css('tt').size  #xpath tt isn't working because it's not selecting all children (possible TODO later)
      if node.children.size > 0 && tt_size > 0 
        first_child = node.children.first
        control_node = Nokogiri::XML::Node.new('span', doc)
        control_node['class'] = "paragraph-numbering"
        control_node.inner_html = "#{count}"
        first_child.add_previous_sibling(control_node)
        count += 1
      end 
    end 

    CGI.unescapeHTML(doc.xpath("//html/body/*").to_s)
  end

  alias :to_s :display_name

  def bookmark_name
    self.name
  end

  private 

  def prepare_content
    if self.content.blank?
      content_to_prepare = self.annotatable.content.gsub(/<br>/,'<br /> ')
      doc = Nokogiri::HTML.parse(content_to_prepare)
      doc.xpath('//*').each do |child|
        child.children.each do|c|
          if c.class == Nokogiri::XML::Text && ! c.content.blank?
            text_content = c.content.scan(/\S*\s*/).delete_if(&:empty?).map do |word|
              "<tt>" + word + '</tt> '
            end.join(' ')

            c.swap(text_content)
          end
        end
      end
      class_counter = 1
      indexable_content = []
      doc.xpath('//tt').each do |n|
        n['id'] = "t#{class_counter}"
        class_counter +=1
        indexable_content << n.text.strip
      end
      self.word_count = class_counter
      self.indexable_content = indexable_content.join(' ')
      self.content = doc.xpath("//html/body/*").to_s
    end
  end
end

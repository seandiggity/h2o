class ItemMedia < ActiveRecord::Base
  include AuthUtilities
  include PlaylistUtilities

  acts_as_authorization_object

  has_one :playlist_item, :as => :resource_item, :dependent => :destroy
  validates_presence_of :name
  belongs_to :actual_object, :polymorphic => true
  
  def word_count
    self.actual_object ? self.actual_object.effective_word_count : 0
  end
end

class UserCollection < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_and_belongs_to_many :users
  has_and_belongs_to_many :playlists
  has_many :permission_assignments

  validates_presence_of :owner_id, :name

  accepts_nested_attributes_for :permission_assignments
end

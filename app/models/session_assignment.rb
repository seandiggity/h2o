class SessionAssignment < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :playlist_item
end

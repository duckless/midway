class Participant < ActiveRecord::Base
  attr_accessible :last_location, :session_id, :uuid
  belongs_to :session
  validates :uuid, presence: true
  validates :last_location, presence: true
end

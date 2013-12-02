class Participants < ActiveRecord::Base
  attr_accessible :last_location, :session_id, :uuid
  belong_to :session
end

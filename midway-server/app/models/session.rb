class Session < ActiveRecord::Base
  attr_accessible :session_id
  has_many :participants, :dependent: :destroy
end

class Session < ActiveRecord::Base
  attr_accessible :session_id
  has_many :participants, dependent: :destroy

  before_create :generate_unique_session_id

  private

    def generate_unique_session_id
      self.session_id = loop do
        random_session_id = sprintf('%07d', rand(10**10))
        break random_session_id unless Session.exists?(session_id: random_session_id)
      end
    end
end

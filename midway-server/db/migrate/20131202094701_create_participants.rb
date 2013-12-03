class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.belongs_to :session
      t.string :uuid
      t.string :last_location

      t.timestamps
    end
  end
end

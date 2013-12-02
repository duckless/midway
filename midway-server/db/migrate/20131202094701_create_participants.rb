class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.integer :session_id
      t.string :uuid
      t.string :last_location

      t.timestamps
    end
  end
end

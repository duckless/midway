class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :session_id

      t.timestamps
    end

    add_index :sessions, :session_id
  end
end

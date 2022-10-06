class AddFactionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :faction, null: true, foreign_key: true
  end
end

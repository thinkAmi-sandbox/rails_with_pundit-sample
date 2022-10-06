class CreateFactions < ActiveRecord::Migration[7.0]
  def change
    create_table :factions do |t|
      t.string :name

      t.timestamps
    end
  end
end

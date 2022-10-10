class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.references :user, null: true, foreign_key: true
      t.references :secret_message, null: false, foreign_key: true

      t.timestamps
    end
  end
end

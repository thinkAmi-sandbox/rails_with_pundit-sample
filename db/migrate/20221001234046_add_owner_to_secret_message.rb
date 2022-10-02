class AddOwnerToSecretMessage < ActiveRecord::Migration[7.0]
  def change
    add_reference :secret_messages, :owner, foreign_key: { to_table: :users }
  end
end

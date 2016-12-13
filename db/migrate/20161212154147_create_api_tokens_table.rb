class CreateApiTokensTable < ActiveRecord::Migration[5.0]
  def change
    create_table :api_tokens do |t|
      t.string :token
      t.integer :roles_mask

      t.timestamps
    end

    add_index :api_tokens, :token, :unique => true
  end
end

class CreateTokenGeneratorsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :token_generators do |t|
      t.string :name
      t.text :description
      t.string :secret
      t.integer :token_ttl

      t.timestamps
    end

    add_index :token_generators, :name, :unique => true
  end
end

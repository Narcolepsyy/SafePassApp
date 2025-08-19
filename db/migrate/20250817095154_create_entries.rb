class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.string :name
      t.string :url
      t.string :username
      t.string :password
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

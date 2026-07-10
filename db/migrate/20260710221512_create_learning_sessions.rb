class CreateLearningSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :learning_sessions do |t|
      t.references :goal, null: false, foreign_key: true
      t.date :date
      t.integer :duration
      t.text :notes
      t.string :tags

      t.timestamps
    end
  end
end

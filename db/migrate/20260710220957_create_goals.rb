# status is an integer enum (see app/models/goal.rb) — default 0 = planned,
# so a goal created without an explicit status is never left in a null state.
class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end

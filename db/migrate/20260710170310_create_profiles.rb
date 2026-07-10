# The "who is this person" data, separate from User's credentials.
# focus_areas is a plain comma-separated string (not serialized/JSON) —
# simplest thing that works for a handful of tags; the view splits it.
class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :cohort
      t.string :focus_areas

      t.timestamps
    end
  end
end

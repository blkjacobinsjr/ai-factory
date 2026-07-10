# Creates the bookmarks table — the app's only data store so far.
# title: what the user sees on the list; url: where clicking it goes.
# Both are plain strings; the *format* rules live in the Bookmark model,
# because SQLite won't enforce them and every write goes through the model.
class CreateBookmarks < ActiveRecord::Migration[8.1]
  def change
    create_table :bookmarks do |t|
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end

# Evolves the standalone, globally-shared Bookmark into a Resource
# attached to a Goal. Existing rows have no user/goal owner to assign them
# to (they're dev/test-only data, never a real user's), so they're removed
# rather than guessed at — documented here, not silently dropped.
#
# resource_type (NOT "type"): Rails treats a column literally named "type"
# as a Single Table Inheritance discriminator, which would silently break
# every query on this table — a plain enum column needs a different name.
class ConvertBookmarksToResources < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up { execute "DELETE FROM bookmarks" }
    end

    rename_table :bookmarks, :resources
    add_reference :resources, :goal, null: false, foreign_key: true
    add_column :resources, :resource_type, :integer, default: 0, null: false
  end
end

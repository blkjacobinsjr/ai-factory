# Only the LATEST summary/next-steps are kept per goal (overwritten each
# time, per the ticket's own out-of-scope note) — no history table needed.
class AddAiInsightsToGoals < ActiveRecord::Migration[8.1]
  def change
    add_column :goals, :ai_summary, :text
    add_column :goals, :ai_next_steps, :text
  end
end

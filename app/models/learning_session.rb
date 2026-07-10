# One logged block of time spent working toward a Goal. Reached only
# through Current.user.learning_sessions (a through: :goals association on
# User) or @goal.learning_sessions — never LearningSession.find directly,
# same scoping discipline as Goal.
class LearningSession < ApplicationRecord
  belongs_to :goal
end

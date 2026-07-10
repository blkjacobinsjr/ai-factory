# Same two validations Bookmark had, now on Resource (which additionally
# requires a goal — see app/models/resource.rb).
require "test_helper"

class ResourceTest < ActiveSupport::TestCase
  test "is invalid with a blank title" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")
    resource = goal.resources.build(title: "", url: "https://example.com")

    assert_not resource.valid?
    assert resource.errors[:title].any?
  end

  test "is invalid when url is not http or https" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")
    resource = goal.resources.build(title: "Broken", url: "not-a-url")

    assert_not resource.valid?
    assert resource.errors[:url].any?
  end
end

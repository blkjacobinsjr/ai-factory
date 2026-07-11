# The only method that touches the real network is send_request — these
# tests stub just that layer to prove the error-handling contract without
# a real HTTP call.
require "test_helper"

class AiInsightServiceTest < ActiveSupport::TestCase
  test "raises Error when the AI provider responds with a non-success status" do
    goal = users(:one).goals.create!(title: "Learn Rails", status: "planned")
    fake_response = Net::HTTPInternalServerError.new("1.1", "500", "Internal Server Error")

    stub_class_method(AiInsightService, :send_request, fake_response) do
      assert_raises(AiInsightService::Error) { AiInsightService.summarize(goal) }
    end
  end
end

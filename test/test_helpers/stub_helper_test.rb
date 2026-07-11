# stub_helper.rb itself needs a test — a bug here would silently corrupt
# every future ticket's tests that use stub_class_method, exactly as
# ticket 007's review caught (define_singleton_method always makes a
# method public, even when restoring a class method that was private).
require "test_helper"

class StubHelperTest < ActiveSupport::TestCase
  test "restores original private visibility after stubbing a class method" do
    klass = Class.new do
      def self.secret
        "original"
      end
      private_class_method :secret
    end

    stub_class_method(klass, :secret, "stubbed") { }

    assert_not klass.respond_to?(:secret), "expected :secret to remain private after stubbing, not leak public"
  end
end

# Minitest 6 (this app's version, via Gemfile.lock) removed minitest/mock
# entirely — no Object#stub, no Minitest::Mock. Rather than add a whole
# mocking gem (mocha etc.) for one narrow need, this is the minimal
# replacement: temporarily redefine a class method, always restore it.
module StubHelper
  def stub_class_method(klass, method_name, value_or_callable)
    original = klass.method(method_name)
    # define_singleton_method always makes the method PUBLIC, even when
    # restoring one that was private (AiInsightService.send_request, e.g.)
    # — without tracking this, every use of this helper on a private class
    # method permanently leaks it public for the rest of the test process.
    was_private = klass.singleton_class.private_method_defined?(method_name)
    replacement = value_or_callable.respond_to?(:call) ? value_or_callable : -> (*) { value_or_callable }
    klass.define_singleton_method(method_name, &replacement)
    yield
  ensure
    klass.define_singleton_method(method_name, original)
    klass.send(:private_class_method, method_name) if was_private
  end
end

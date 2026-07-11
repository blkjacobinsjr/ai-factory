# Minitest 6 (this app's version, via Gemfile.lock) removed minitest/mock
# entirely — no Object#stub, no Minitest::Mock. Rather than add a whole
# mocking gem (mocha etc.) for one narrow need, this is the minimal
# replacement: temporarily redefine a class method, always restore it.
module StubHelper
  def stub_class_method(klass, method_name, value_or_callable)
    original = klass.method(method_name)
    replacement = value_or_callable.respond_to?(:call) ? value_or_callable : -> (*) { value_or_callable }
    klass.define_singleton_method(method_name, &replacement)
    yield
  ensure
    klass.define_singleton_method(method_name, original)
  end
end

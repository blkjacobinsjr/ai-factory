# Tests the reader for .factory/state — the file the AI-factory hooks
# maintain. The homepage badge shows whatever this returns, so a wrong
# parse would display a phase the factory isn't actually in.
require "test_helper"

class FactoryStateTest < ActiveSupport::TestCase
  test "reads phase from a state file, idle when missing" do
    Tempfile.create("state") do |f|
      f.write("phase=implementing\nticket=003\nverdict=\n")
      f.flush

      assert_equal "implementing", FactoryState.phase(f.path)
    end

    # Missing file must NOT raise: the app may be deployed without .factory/
    # (it's a dev-machine artifact), and the homepage still has to render.
    assert_equal "idle", FactoryState.phase("/nonexistent/state")
  end

  test "any unreadable path falls back to idle instead of crashing" do
    # A directory (EISDIR) stands in for the whole family of filesystem
    # errors (permissions, etc.) — none of them may 500 the homepage,
    # because the strip is decoration, not a dependency. (Review F3.)
    assert_equal "idle", FactoryState.phase(Dir.tmpdir)
  end
end

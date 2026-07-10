# Reads the AI factory's state file (.factory/state) so the homepage can
# show which pipeline phase the factory is in right now. Plain Ruby class,
# not a database model — the "database" here is a four-line key=value file
# maintained by .claude/hooks/set-state.sh. This class only ever READS it;
# writing stays the shell hook's exclusive job, so there's a single mutator.
class FactoryState
  DEFAULT_PATH = -> { Rails.root.join(".factory/state") }

  # Returns the current phase string ("refined", "implementing", …).
  # Falls back to "idle" if the file or key is missing — a deployed copy of
  # this app won't have .factory/, and the homepage must not crash for that.
  def self.phase(path = DEFAULT_PATH.call)
    line = File.foreach(path).find { |l| l.start_with?("phase=") }
    value = line&.split("=", 2)&.last&.strip
    value.presence || "idle"
  rescue Errno::ENOENT
    "idle"
  end
end

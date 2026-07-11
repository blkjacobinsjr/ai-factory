# Calls the OpenAI Chat Completions API (plain Net::HTTP — no SDK gem,
# per the ticket's own preference) to generate a progress summary or a
# short list of next steps for a Goal, from its recent learning sessions
# and resources.
#
# send_request is the ONLY method that touches the network — tests stub
# either the public methods (summarize/next_steps) or, for the error-
# handling path, this one method, since this app has no webmock/vcr. That
# means NOTHING in the automated suite ever actually loads Net::HTTP — a
# missing require here only surfaced via a real API call during review
# (bin/rails runner, fresh process: NameError: uninitialized constant
# Net::HTTP). A narrow automated test for "is Net::HTTP required" would be
# unreliable — Rails may load it transitively elsewhere in the full test
# process regardless of whether THIS file's require does anything.
require "net/http"
require "json"

class AiInsightService
  # Raised for anything that goes wrong talking to the AI provider —
  # network failure, non-success HTTP response, or an unparseable reply.
  # Controllers rescue this specifically (not a bare StandardError) so an
  # unrelated bug elsewhere can't get silently swallowed by the same net.
  class Error < StandardError; end

  # Env-overridable, not hardcoded: if this default model name goes stale
  # (models get deprecated), fixing it is a config change, not a deploy.
  MODEL = ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")

  def self.summarize(goal)
    chat(summary_prompt(goal))
  end

  def self.next_steps(goal)
    chat(next_steps_prompt(goal))
  end

  def self.summary_prompt(goal)
    <<~PROMPT
      Goal: #{goal.title}
      Description: #{goal.description}

      Recent learning sessions:
      #{context_lines(goal)}

      Write a concise 2-3 sentence progress summary for this learner:
      what they've covered so far and what to focus on next.
    PROMPT
  end

  def self.next_steps_prompt(goal)
    <<~PROMPT
      Goal: #{goal.title}
      Description: #{goal.description}

      Recent learning sessions:
      #{context_lines(goal)}

      Suggest 2-3 concrete next learning actions for this goal. Reply
      with ONE action per line, no numbering, no bullets, nothing else.
    PROMPT
  end

  def self.context_lines(goal)
    sessions = goal.learning_sessions.order(date: :desc).limit(10).map do |s|
      "- #{s.date}: #{s.duration} min. Notes: #{s.notes}"
    end
    resources = goal.resources.order(created_at: :desc).limit(10).map do |r|
      "- #{r.title} (#{r.resource_type})"
    end
    (sessions + resources).join("\n").presence || "(none logged yet)"
  end
  private_class_method :summary_prompt, :next_steps_prompt, :context_lines

  def self.chat(prompt)
    response = send_request(prompt)
    parse_response(response)
  end

  def self.send_request(prompt)
    uri = URI("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV.fetch('OPENAI_API_KEY')}"
    })
    request.body = { model: MODEL, messages: [{ role: "user", content: prompt }], max_tokens: 300 }.to_json
    http.request(request)
  rescue StandardError => e
    # Any network-level failure (timeout, DNS, connection refused) — wrap
    # it so callers only ever handle ONE error type, not a grab-bag of
    # Ruby/Net::HTTP internals.
    raise Error, "could not reach the AI provider: #{e.message}"
  end

  def self.parse_response(response)
    raise Error, "AI request failed (HTTP #{response.code})" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).dig("choices", 0, "message", "content").to_s.strip
  rescue JSON::ParserError
    raise Error, "AI response was not valid JSON"
  end
  private_class_method :chat, :send_request, :parse_response
end

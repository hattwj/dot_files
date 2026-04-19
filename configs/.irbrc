# ~/.irbrc
# Maximum compatibility across Ruby 2.0 through 4.x.
# Every section is wrapped in begin/rescue: if anything fails, IRB still starts
# cleanly with whatever the previous sections managed to configure.

# --- History (per-Ruby-version file to avoid Readline/Reline format clashes) ---
begin
  # Old IRB needs this require. Modern IRB has it built in; the require is a no-op.
  begin
    require 'irb/ext/save-history'
  rescue LoadError
    # modern IRB, nothing to do
  end

  ruby_tag = RUBY_VERSION[/^\d+\.\d+/] || 'unknown'
  IRB.conf[:SAVE_HISTORY] = 10_000
  IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history_#{ruby_tag}"
rescue StandardError
end

# --- Pager with /search (works via shell; no IRB cooperation required) ---
begin
  # -F: quit if output fits on one screen (short results stay inline)
  # -R: render raw ANSI color codes
  # -X: don't clear screen on exit (keeps output visible)
  ENV['PAGER'] ||= 'less -FRX'
  ENV['LESS']  ||= '-FRX'
rescue StandardError
end

# --- Modern IRB features (IRB 1.2+ / Ruby 2.7+). Setting unknown keys on ---
# --- IRB.conf is harmless on older IRB; the keys are simply ignored. ---
begin
  IRB.conf[:USE_PAGER]        = true
  IRB.conf[:USE_COLORIZE]     = true
  IRB.conf[:USE_AUTOCOMPLETE] = true
  IRB.conf[:AUTO_INDENT]      = true
rescue StandardError
end

# --- Prompt shows Ruby version so I always know which interpreter I'm in ---
begin
  ruby_ver = RUBY_VERSION
  IRB.conf[:PROMPT] ||= {}
  IRB.conf[:PROMPT][:HATT] = {
    :PROMPT_I => "[#{ruby_ver}] >> ",
    :PROMPT_S => "[#{ruby_ver}] %l> ",
    :PROMPT_C => "[#{ruby_ver}]  > ",
    :RETURN   => "=> %s\n"
  }
  IRB.conf[:PROMPT_MODE] = :HATT
rescue StandardError
end

begin
  Pry.config.history.file = "~/.irb_history"
rescue NoMethodError
  Pry.config.history_file = "~/.irb_history"
end

module ECSHelper::Logging
  def console(message)
    puts message if ENV["SKIP_LOGS"] != 'true'
  end

  def log(title, message = nil, color = "light_white")
    if message
      console title.send(color)
      console message
    else
      console title
    end
  end

  def error(message, code = 1)
    console "Error".red
    console message
    exit code
  end
end
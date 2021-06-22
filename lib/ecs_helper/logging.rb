module ECSHelper::Logging
  def log(title, message = nil, color = "light_white")
    if message
      puts title.send(color)
      puts message
    else
      puts title
    end
  end

  def error(message)
    puts "Error".red
    puts message
    exit
  end
end
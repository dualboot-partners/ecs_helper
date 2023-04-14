require 'terrapin'

class ECSHelper::Command::ECRLogin < ECSHelper::Command::Base

  def cmd_option_parser
    options = {}
    parser = ::OptionParser.new do |opts|
      opts.banner = "Usage: ecs_helper ecr_login"
    end
    [parser, options]
  end

  def required
    []
  end

  def run
    log("Command", type)
    log("Auth Private", auth_private)
  end

  def auth_private
    auth_cmd = helper.auth_private_cmd
    auth_cmd.run
  end
end

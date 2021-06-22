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
    log("Auth Public", auth_public)
  end

  def auth_public
    auth_cmd = Terrapin::CommandLine.new("aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws")
    auth_cmd.run
  end

  def auth_private
    auth_cmd = Terrapin::CommandLine.new("aws ecr get-login --no-include-email | sh")
    auth_cmd.run
  end
end

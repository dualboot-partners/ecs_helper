
class ECSHelper::Command
  autoload :Base, 'ecs_helper/command/base'
  autoload :BuildAndPush, 'ecs_helper/command/build_and_push'
  autoload :Deploy, 'ecs_helper/command/deploy'
  autoload :ExportImages, 'ecs_helper/command/export_images'
  autoload :ECRLogin, 'ecs_helper/command/ecr_login'
  autoload :RunCommand, 'ecs_helper/command/run_command'

  CMD_MAPPING  = {
    "build_and_push" => BuildAndPush,
    "deploy" => Deploy,
    "export_images" => ExportImages,
    "ecr_login" => ECRLogin,
    "run_command" => RunCommand,
  }
  AVAILABLE_COMMANDS = CMD_MAPPING.keys

  attr_accessor :type, :helper, :command

  def initialize(helper)
    @helper = helper
    @type = ARGV.shift
    @command = klass.new(helper)
  end

  def klass
    CMD_MAPPING[type] || begin
      puts "Command not found".light_white
      puts "Available commands are #{AVAILABLE_COMMANDS}".light_white
      puts global_option_parser
      exit
    end
  end

  def options
    command.options
  end

  def run
    command.validate
    command.run
  end
end

def global_option_parser
  ::OptionParser.new do |opts|
    opts.banner = "Usage: ecs_helper command [options]"
  end
end


def self.parse
  options = {}
  command = ARGV.shift

  unless command && Command::AVAILABLE_COMMANDS.include?(command)
    puts "Command not found".light_white
    puts "Available commands are #{Command::AVAILABLE_COMMANDS}".light_white
    puts global
    exit
  end

  subcommands_parser, required = subcommands(command, options)
  subcommands_parser.permute!(into: options)

  validate(command, options, required, subcommands_parser)

  [command, options]
end



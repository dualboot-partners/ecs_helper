require 'optparse'
require 'terrapin'
require 'ecs_helper/logging'

class ECSHelper::Command::Base
  include ECSHelper::Logging
  attr_accessor :type, :options, :helper, :client, :option_parser


  def initialize(helper)
    @client = helper.client
    @helper = helper
    @option_parser, @options = cmd_option_parser
    @option_parser.parse!(into: @options)
  end

  def type
    helper.type
  end

  def project
    helper.project
  end

  def check_bin(bin)
    check_cmd = Terrapin::CommandLine.new("which #{bin}")
    result = check_cmd.run
    "success"
  rescue Terrapin::CommandNotFoundError, Terrapin::ExitStatusError => e
    messages = ["#{bin} not found"]
    raise ECSHelper::Error::BinNotFound.new(messages)
  end

  def application
    helper.application
  end

  def validate
    required.each do |r|
      value = options[r]
      if value.nil?
        messages = [
          "'#{r}' required for command '#{type}'".light_white,
          option_parser.help
        ]
        raise ECSHelper::Error::CommandValidationError.new(messages)
      end
    end
  end

  def required
    []
  end

  def printable?
    false
  end

  private

  def processEqual(value)
    value.start_with?('=') ? value[1..-1] : value
  end
end


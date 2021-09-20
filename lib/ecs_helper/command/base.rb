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

  def application
    helper.application
  end

  def validate
    required.each do |r|
      value = options[r]
      unless value
        puts "'#{r}' required for command '#{type}'".light_white
        puts option_parser.help
        exit
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


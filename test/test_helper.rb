# frozen_string_literal: true

module MyWarningFilter
  def warn(message, category: nil, **kwargs); end
end
Warning.extend MyWarningFilter

require 'ecs_helper'

require 'minitest/autorun'
require 'minitest/power_assert'
require 'mocha/minitest'

require 'webmock'
require 'webmock/minitest'
require 'support/aws_support'
require 'support/ecs_helper_support'
require 'support/stub_support'
require 'pry-byebug'
require 'terrapin'

module Minitest
  class Test
    include ECSHelperSupport
    include StubSupport

    Terrapin::CommandLine.fake!

    def load_fixture(path)
      path = File.expand_path(File.join('..', 'fixtures', path), __FILE__)
      File.read(path)
    end
  end
end

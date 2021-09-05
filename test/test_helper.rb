# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'coveralls'
Coveralls.wear!

require 'ecs_helper'

require 'minitest/autorun'

require 'webmock'
require 'webmock/minitest'

module Minitest
  class Test
    def load_fixture(path)
      path = File.expand_path(File.join('..', 'fixtures', path), __FILE__)
      File.read(path)
    end
  end
end

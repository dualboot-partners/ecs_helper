# frozen_string_literal: true

require 'test_helper'

class ECSHelperTest < Minitest::Test
  def test_that_it_has_a_version_number
    assert { ::ECSHelper::VERSION != nil }
  end

  def test_without_command
    assert_raises ECSHelper::Error::CommandNotFound do
      with_command('') do |setup|
        helper = ECSHelper.new
        helper.run
      end
    end
  end

  def test_incorrect_command
    assert_raises ECSHelper::Error::CommandNotFound do
      with_command('incorrect command') do |setup|
        helper = ECSHelper.new
        helper.run
      end
    end
  end
end

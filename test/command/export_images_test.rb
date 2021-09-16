# frozen_string_literal: true

require 'test_helper'

require 'aws-sdk-ecs'
require 'aws-sdk-ecr'

class ECSHelper::Command::ExportImagesTest < Minitest::Test
  def test_export_env_secrets_with_no_vars
    command = 'export_images'

    with_command(command) do |setup|
      repo = stub_private_repositories(setup)

      helper = ECSHelper.new
      export_string = helper.run
      assert (export_string =~ /^export/)

      assert (export_string =~ /WEB_IMAGE=#{repo[:repository_uri]}.*/)
    end
  end
end


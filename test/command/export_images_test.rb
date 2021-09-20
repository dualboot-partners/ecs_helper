# frozen_string_literal: true

require 'test_helper'

require 'aws-sdk-ecs'
require 'aws-sdk-ecr'

class ECSHelper::Command::ExportImagesTest < Minitest::Test
  def test_export_env_secrets_with_no_vars
    command = 'export_images'

    with_command(command) do |setup|
      repo = AwsSupport.repository("#{setup.project}-#{setup.application}-web")
      stub_repositories([repo])

      helper = ECSHelper.new
      image_regexp = /^export.+WEB_IMAGE=#{repo[:repository_uri]}.*/

      assert_output(image_regexp) do
        export_string = helper.run
        assert (export_string =~ image_regexp)
      end
    end
  end
end

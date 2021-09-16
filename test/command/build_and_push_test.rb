# frozen_string_literal: true

require 'test_helper'

require 'aws-sdk-ecs'
require 'aws-sdk-ecr'

class ECSHelper::Command::BuildAndPushTest < Minitest::Test
  def test_build_and_push_with_cache
    command = 'build_and_push --image=web --cache'
    cache = true

    with_command(command) do |setup|
      repo = stub_private_repositories(setup)

      stub_auth()
      stub_pull(repo[:repository_uri])
      stub_build(repo[:repository_uri], setup.version, cache)
      stub_push(repo[:repository_uri], setup.version)

      helper = ECSHelper.new
      helper.run
    end
  end

  def test_build_and_push_without_cache
    command = 'build_and_push --image=web'
    cache = false

    with_command(command) do |setup|
      repo = stub_private_repositories(setup)

      stub_auth()
      stub_build(repo[:repository_uri], setup.version, cache)
      stub_push(repo[:repository_uri], setup.version)

      helper = ECSHelper.new
      helper.run
    end
  end
end


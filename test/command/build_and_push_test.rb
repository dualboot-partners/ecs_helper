# frozen_string_literal: true

require 'test_helper'

require 'aws-sdk-ecs'
require 'aws-sdk-ecr'

class ECSHelper::Command::BuildAndPushTest < Minitest::Test
  def test_build_and_push_with_cache
    command = 'build_and_push --image=web --cache'
    cache = true

    with_command(command) do |setup|
      repo = prepare_data(setup)

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
      repo = prepare_data(setup)

      stub_auth()
      stub_build(repo[:repository_uri], setup.version, cache)
      stub_push(repo[:repository_uri], setup.version)

      helper = ECSHelper.new
      helper.run
    end
  end


  private

  def prepare_data(setup)
    name1 = "web"
    name2 = "#{setup.project}-#{setup.application}-web"

    repo1 = { repository_arn: repository_arn(name1), repository_name: repository_name(name1), repository_uri: repository_uri(name1) }
    repo2 = { repository_arn: repository_arn(name2), repository_name: repository_name(name2), repository_uri: repository_uri(name2) }

    ::Aws.config[:ecr] = {
      stub_responses: {
        describe_repositories: { repositories: [ repo1, repo2 ] }
      }
    }
    return repo2
  end
end


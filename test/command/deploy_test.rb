# frozen_string_literal: true

require 'test_helper'

class ECSHelper::Command::DeployTest < Minitest::Test

  def test_deploy_with_timeout_and_two_deployments
    timeout = 2
    deployments = 2
    container = 'web'
    command = "deploy -t=#{timeout}"

    assert_raises SystemExit do
      with_command(command) do |setup|
        cluster_arn, service_arn, task_arn = prepare_data(setup)
        expected = "Application was succesfully deployed"
        task_definition = AwsSupport.task_definition(container)
        stub_describe_task_definition(task_definition)

        services = AwsSupport.services(setup.project, setup.application, setup.env, deployments)
        stub_describe_services(services)

        repo = AwsSupport.repository("#{setup.project}-#{setup.application}-web")
        stub_repositories([repo])

        helper = ECSHelper.new
        helper.run
      end
    end
  end

  def test_deploy_with_timeout_and_one_deployments
    timeout = 2
    deployments = 1
    container = 'web'
    command = "deploy -t=#{timeout}"

    with_command(command) do |setup|
      cluster_arn, service_arn, task_arn = prepare_data(setup)
      expected = "Application was succesfully deployed"
      task_definition = AwsSupport.task_definition(container)
      stub_describe_task_definition(task_definition)

      services = AwsSupport.services(setup.project, setup.application, setup.env, deployments)
      stub_describe_services(services)

      repo = AwsSupport.repository("#{setup.project}-#{setup.application}-web")
      stub_repositories([repo])

      helper = ECSHelper.new
      helper.run
    end
  end

  private

  def prepare_data(setup)
    clusters = [
      AwsSupport.cluster_arn(setup.project, setup.environment),
      AwsSupport.cluster_arn(setup.project, 'uat')
    ]
    services = [
      AwsSupport.service_arn(setup.project, setup.application, setup.environment),
      AwsSupport.service_arn(setup.project, setup.application, 'uat'),
      AwsSupport.service_arn(setup.project, 'another-app', setup.environment),
      AwsSupport.service_arn(setup.project, 'another-app', 'uat'),
    ]
    task_arn = AwsSupport.task_arn(setup.project, setup.environment)
    stub_clusters(clusters)
    stub_services(services)
    stub_list_tasks([task_arn])
    [clusters[0], services[0], task_arn]
  end
end

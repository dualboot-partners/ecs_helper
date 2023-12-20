# frozen_string_literal: true

require 'test_helper'

class ECSHelper::Command::RunCommandTest < Minitest::Test

  def test_deploy_with_timeout_and_pending_status
    container = 'web'
    command = "run_command --command=\"make prepare_db\" --name=\"db-migrate\" -t=0"

    assert_raises SystemExit do
      with_command(command) do |setup|
        cluster_arn, service_arn, task_arn = prepare_data(setup)

        task_definition = AwsSupport.task_definition(container)
        stub_describe_task_definition(task_definition)

        services = AwsSupport.services(setup.project, setup.application, setup.env, 1)
        stub_describe_services(services)

        stub_register_task_definition(task_definition)

        repo = AwsSupport.repository("#{setup.project}-#{setup.application}-#{container}")
        stub_repositories([repo])

        task = AwsSupport.task(setup.project, setup.environment, container, 'PENDING', nil)
        stub_run_task([task])
        stub_describe_tasks([task])

        helper = ECSHelper.new
        helper.run
      end
    end
  end

  def test_deploy_with_timeout_stopped_status_and_zero_exit_code
    container = 'web'
    command = "run_command --command \"make prepare_db\" --name \"db-migrate\" -t 0"

    with_command(command) do |setup|
      cluster_arn, service_arn, task_arn = prepare_data(setup)

      task_definition = AwsSupport.task_definition(container)
      stub_describe_task_definition(task_definition)

      services = AwsSupport.services(setup.project, setup.application, setup.env, 1)
      stub_describe_services(services)

      stub_register_task_definition(task_definition)

      repo = AwsSupport.repository("#{setup.project}-#{setup.application}-#{container}")
      stub_repositories([repo])

      task = AwsSupport.task(setup.project, setup.environment, container, 'STOPPED', 0)
      stub_run_task([task])
      stub_describe_tasks([task])

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

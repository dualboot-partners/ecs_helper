# frozen_string_literal: true

require 'test_helper'

class ECSHelper::Command::CheckExecTest < Minitest::Test
  def test_exec_without_check_ecs_exec
    command = 'check_exec'

    assert_raises ECSHelper::Error::BinNotFound do
      with_command(command) do |setup|
        repo = prepare_data(setup)

        helper = ECSHelper.new
        helper.run
      end
    end
  end

  def test_exec_with_check_ecs_exec
    command = 'check_exec'
    result = 'Success'

    with_command(command) do |setup|
      cluster_arn, service_arn, task_arn = prepare_data(setup)

      stub_bin("check-ecs-exec", '/usr/local/bin/check-ecs-exec')
      stub_check_ecs_exec(cluster_arn, task_arn, result)
      helper = ECSHelper.new

      assert_output("#{result}\n") do
        result_string = helper.run
        assert result == result_string
      end
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

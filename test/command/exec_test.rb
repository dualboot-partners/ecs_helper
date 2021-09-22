# frozen_string_literal: true

require 'test_helper'

class ECSHelper::Command::ExecTest < Minitest::Test
  def test_exec_no_container
    command = 'exec'

    assert_raises ECSHelper::Error::CommandValidationError do
      with_command(command) do |setup|
        repo = prepare_data(setup)

        helper = ECSHelper.new
        helper.run
      end
    end
  end

  def test_exec_without_session_manager
    containers = ['web', 'sidekiq']
    command = 'exec -c=web'

    assert_raises ECSHelper::Error::BinNotFound do
      with_command(command) do |setup|
        repo = prepare_data(setup)

        helper = ECSHelper.new
        helper.run
      end
    end
  end

  def test_exec_with_old_awscli
    containers = ['web', 'sidekiq']
    command = 'exec -c=web'

    stub_bin("session-manager-plugin", '/usr/local/bin/session-manager-plugin')
    stub_bin("aws", '/usr/bin/aws')
    stub_aws_cli(:v1)

    assert_raises ECSHelper::Error::CommandValidationError do
      with_command(command) do |setup|
        prepare_data(setup)
        helper = ECSHelper.new
        helper.run
      end
    end
  end

  def test_exec_with_new_awscli
    container = 'web'
    cmd = '/bin/bash'
    command = "exec -c=#{container} --command=#{cmd}"

    stub_bin("session-manager-plugin", '/usr/local/bin/session-manager-plugin')
    stub_bin("aws", '/usr/bin/aws')
    stub_aws_cli(:v2)

    with_command(command) do |setup|
      cluster_arn, service_arn, task_arn = prepare_data(setup)
      stub_exec(cluster_arn, task_arn, container, cmd)

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

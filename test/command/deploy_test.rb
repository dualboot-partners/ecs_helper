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


  # opts.banner = "Usage: ecs_helper deploy [options]"
  # opts.on("-p VALUE", "--project VALUE", "Set project name, if not specified will look at ENV['PROJECT'], will be used to detect cluster") { |p| options[:project] = processEqual(p) }
  # opts.on("-a VALUE", "--application VALUE", "Set application name, if not specified will look at ENV['APPLICATION'], will be used to detect service and task definition") { |a| options[:application] = processEqual(a) }
  # opts.on("-e VALUE", "--environment VALUE", "Set environment, if not specified will look at ENV['ENVIRONMENT'], it there is empty will try to detect based on the branch") { |e| options[:environment] = processEqual(e) }
  # opts.on("-v VALUE", "--version VALUE", "Set version which will be applied to all containers in the task if tag is present in the repo") { |t| options[:version] = processEqual(t) }
  # opts.on("-cl VALUE", "--cluster VALUE", "Set cluster name, could be autodetected if project and environment are specified") { |c| options[:cluster] = processEqual(c) }
  # opts.on("-s VALUE", "--service VALUE", "Set service, could be autodetected if application and environment are specified") { |s| options[:service] = processEqual(s) }
  # opts.on("-t VALUE", "--timeout VALUE", "Set timeout how long to wait until deployment finished") { |t| options[:timeout] = processEqual(t) }

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

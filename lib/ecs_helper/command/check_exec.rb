# frozen_string_literal: true

require 'terrapin'

class ECSHelper::Command::CheckExec < ECSHelper::Command::Base
  def cmd_option_parser
    options = { command: 'bash -c' }
    parser = ::OptionParser.new do |opts|
      opts.banner = 'Usage: ecs_helper check_exec'
      opts.on('-p VALUE', '--project VALUE', "Set project name, if not specified will look at ENV['PROJECT'], will be used to detect cluster") do |p| options[:project] = processEqual(p) end
      opts.on('-a VALUE', '--application VALUE', "Set application name, if not specified will look at ENV['APPLICATION'], will be used to detect service and task definition") do |a| options[:application] = processEqual(a) end
    end
    [parser, options]
  end

  def check_exec_bin
    check_bin('check-ecs-exec')
  end

  def check_exec
    exec_cmd = Terrapin::CommandLine.new("check-ecs-exec #{cluster_arn} #{task_arn}")
    exec_cmd.run
  end

  def printable?
    true
  end

  def run
    log("Command", type)
    log("Cluster", cluster_arn)
    log("Service", service_arn)
    log("Task", task_arn)
    log("Options", options)
    log("Check bin", check_exec_bin)
    check_exec
  end

  private

  def cluster_arn
    helper.current_cluster
  end

  def service_arn
    helper.current_service
  end

  def task_arn
    @task_arn ||= helper.client.list_tasks({cluster: cluster_arn, service_name: service_arn, desired_status: "RUNNING"})[0]
  end
end

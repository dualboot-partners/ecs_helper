# frozen_string_literal: true

require 'terrapin'

class ECSHelper::Command::Exec < ECSHelper::Command::Base
  def cmd_option_parser
    options = { command: 'bash -c' }
    parser = ::OptionParser.new do |opts|
      opts.banner = 'Usage: ecs_helper exec [options]. require session-manager-plugin and aws cli v2'
      opts.on('-p VALUE', '--project VALUE',
              "Set project name, if not specified will look at ENV['PROJECT'], will be used to detect cluster") do |p|
        options[:project] = processEqual(p)
      end
      opts.on('-a VALUE', '--application VALUE',
              "Set application name, if not specified will look at ENV['APPLICATION'], will be used to detect service and task definition") do |a|
        options[:application] = processEqual(a)
      end
      opts.on('-c', '--container VALUE', 'Cache image before build, default false') { |c| options[:container] = c }
      opts.on('--command VALUE', 'Command to execute') { |c| options[:command] = c }
    end
    [parser, options]
  end

  def required
    [:container]
  end

  def check_session_manager_plugin
    check_bin('session-manager-plugin')
  end

  def check_aws_cli_version
    check_cmd = Terrapin::CommandLine.new("aws --version")
    result = check_cmd.run
    version = parse_version(result)
    if version === "1"
      messages = [
        "Exec command requires aws cli v2".light_white,
        cmd_option_parser[0].help
      ]
      raise ECSHelper::Error::CommandValidationError.new(messages)
    end
  end

  def check_aws_cli
    check_bin('aws')
    check_aws_cli_version
    "success"
  end


  def check_aws_cli_version
    check_cmd = Terrapin::CommandLine.new("aws --version")
    result = check_cmd.run
    version = parse_version(result)
    if version === "1"
      messages = [
        "Exec command requires aws cli v2".light_white,
        cmd_option_parser[0].help
      ]
      raise ECSHelper::Error::CommandValidationError.new(messages)
    end
  end

  def run
    log("Command", type)
    log("Cluster", cluster_arn)
    log("Service", service_arn)
    log("Task", task_arn)
    log("Options", options)
    log("Check session-manager-plugin ", check_session_manager_plugin)
    log("Check aws cli version", check_aws_cli)
    exec
  end

  def exec
    exec_cmd = Terrapin::CommandLine.new("aws ecs execute-command --cluster #{cluster_arn} --task #{task_arn}  --container=#{helper.options[:container]} --command=#{helper.options[:command]}  --interactive")
    # --region us-east-1
    exec_cmd.run
  end

  private

  def parse_version(string)
    string.split('/')[1][0]
  end

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

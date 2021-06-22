require 'terrapin'

class ECSHelper::Command::RunCommand < ECSHelper::Command::Base
  attr_accessor :repositories, :task_definition, :new_task_definition, :service
  DEFAULT_TIMEOUT = 300
  STEP = 5

  def cmd_option_parser
    options = {}
    parser = ::OptionParser.new do |opts|
      opts.banner = "Usage: ecs_helper run_command [options]"
      opts.on("-p VALUE", "--project VALUE", "Set project name, if not specified will look at ENV['PROJECT'], will be used to detect cluster") { |p| options[:project] = processEqual(p) }
      opts.on("-a VALUE", "--application VALUE", "Set application name, if not specified will look at ENV['APPLICATION'], will be used to detect service and task definition") { |a| options[:application] = processEqual(a) }
      opts.on("-e VALUE", "--environment VALUE", "Set environment, if not specified will look at ENV['ENVIRONMENT'], it there is empty will try to detect based on the branch") { |e| options[:environment] = processEqual(e) }
      opts.on("-v VALUE", "--version VALUE", "Set version which will be applied to all containers in the task if tag is present in the repo") { |t| options[:version] = processEqual(t) }
      opts.on("--cluster VALUE", "Set cluster name, could be autodetected if project and environment are specified") { |c| options[:cluster] = processEqual(c) }
      opts.on("-s VALUE", "--service VALUE", "Set service, could be autodetected if application and environment are specified") { |s| options[:service] = processEqual(s) }
      opts.on("-t VALUE", "--timeout VALUE", "Set timeout how long to wait until deployment finished") { |t| options[:timeout] = processEqual(t) }
      opts.on("--command VALUE", "Set command, should not demonize container") { |c| options[:command] = processEqual(c) }
      opts.on("-n VALUE", "--name VALUE", "Set name (will be used for task definition name and log prefix") { |l| options[:name] = processEqual(l) }
      opts.on("--container-name VALUE", "Set container name (default is the first container") { |cn| options[:container_name] = processEqual(cn) }
    end
    [parser, options]
  end

  def required
    [:name, :command]
  end

  def run
    task_definition_helper = ECSHelper::TaskDefinitionHelper.new(helper, service)
    service_task_definition = task_definition_helper.service_task_definition
    new_task_definition_hash = task_definition_helper.new_task_definition_hash
    custom_task_definition_hash = custom_task_definition(new_task_definition_hash)
    custom_task_definition = task_definition_helper.register_task_definition(custom_task_definition_hash)

    log("Command", type)
    log("Options", options)
    log("Environment", environment)
    log("Cluster", cluster_arn)
    log("Service", service_arn)
    log("Version", version)
    log("New task definition", custom_task_definition.task_definition_arn)
    task = run_task(custom_task_definition.task_definition_arn)
    log("Start task", "Task #{task.task_arn} was started")
    log("Waiting for task job...")
    wait_for_task(task.task_arn) && log("Success", "Task finished successfully", :cyan)
  end

  def run_task(task_definition_arn)
    helper.client.run_task({
      cluster: cluster_arn,
      task_definition: task_definition_arn,
      network_configuration: service.network_configuration.to_hash,
      launch_type: service.launch_type
    })
  end

  def task(arn)
    helper.client.describe_tasks({ cluster: cluster_arn, tasks: [arn] })[0]
  end

  def wait_for_task(task_arn, time = 0)
    task = task(task_arn)
    container = task.containers[0];
    log("container: #{container.name}, time: #{time}, timeout: #{timeout}, status: #{container.last_status}, exit_code: #{container.exit_code || 'NONE'}")
    if container.last_status == "STOPPED"
      return true if container.exit_code == 0
      error("Task #{task_arn} finished with exit code #{container.exit_code}")
    end

    error("Task run timeout (#{timeout})") if time > timeout
    sleep STEP
    wait_for_task(task_arn, time + STEP)
  end

  def custom_task_definition(hash)
    hash.merge({
      container_definitions: new_container_definition(hash),
      family: "#{hash[:family]}-#{name}",
    })
  end

  private

  def new_container_definition(hash)
    cds = hash[:container_definitions]
    cds = [cds] if cds.is_a?(Hash)
    cd = container_name ? cds.find {|cd| cd[:name] === container_name} : cds.first
    error("Container not found") unless cd
    new_cd = cd.merge({
      command: command,
      log_configuration: new_log_configuration(cd[:log_configuration]),
      name: "#{cd[:name]}-#{name}"
    })
    [new_cd]
  end

  def new_log_configuration(log_configuration)
    options = log_configuration[:options]
    prefix = options["awslogs-stream-prefix"]
    new_prefix = "#{prefix}-#{name}"
    log_configuration.merge(options: options.merge("awslogs-stream-prefix" => new_prefix))
  end

  def command
    ['bash', '-c', "#{options[:command]}"]
  end

  def environment
    helper.environment
  end

  def cluster_arn
    helper.current_cluster
  end

  def service_arn
    helper.current_service
  end

  def version
    options[:version] || helper.version
  end

  def timeout
    options[:timeout] || DEFAULT_TIMEOUT
  end

  def service
    helper.client.describe_service(cluster_arn, service_arn)
  end

  def name
    options[:name]
  end

  def service
    helper.client.describe_service(cluster_arn, service_arn)
  end

  def container_name
    options[:container_name]
  end
end
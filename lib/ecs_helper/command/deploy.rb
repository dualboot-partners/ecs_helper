require 'terrapin'

class ECSHelper::Command::Deploy < ECSHelper::Command::Base
  attr_accessor :repositories, :task_definition, :new_task_definition, :service
  DEFAULT_TIMEOUT = 300
  STEP = 5

  def cmd_option_parser
    options = {}
    parser = ::OptionParser.new do |opts|
      opts.banner = "Usage: ecs_helper deploy [options]"
      opts.on("-p VALUE", "--project VALUE", "Set project name, if not specified will look at ENV['PROJECT'], will be used to detect cluster") { |p| options[:project] = processEqual(p) }
      opts.on("-a VALUE", "--application VALUE", "Set application name, if not specified will look at ENV['APPLICATION'], will be used to detect service and task definition") { |a| options[:application] = processEqual(a) }
      opts.on("-e VALUE", "--environment VALUE", "Set environment, if not specified will look at ENV['ENVIRONMENT'], it there is empty will try to detect based on the branch") { |e| options[:environment] = processEqual(e) }
      opts.on("-v VALUE", "--version VALUE", "Set version which will be applied to all containers in the task if tag is present in the repo") { |t| options[:version] = processEqual(t) }
      opts.on("-cl VALUE", "--cluster VALUE", "Set cluster name, could be autodetected if project and environment are specified") { |c| options[:cluster] = processEqual(c) }
      opts.on("-s VALUE", "--service VALUE", "Set service, could be autodetected if application and environment are specified") { |s| options[:service] = processEqual(s) }
      opts.on("-t VALUE", "--timeout VALUE", "Set timeout how long to wait until deployment finished") { |t| options[:timeout] = processEqual(t) }
    end
    [parser, options]
  end

  def run
    task_definition_helper = ECSHelper::TaskDefinitionHelper.new(helper, service)
    service_task_definition = task_definition_helper.service_task_definition
    new_task_definition_hash = task_definition_helper.new_task_definition_hash
    new_task_definition = task_definition_helper.register_task_definition(new_task_definition_hash)
    log("Command", type)
    log("Options", options)
    log("Environment", environment)
    log("Cluster", cluster_arn)
    log("Service", service_arn)
    log("Version", version)
    log("Service task definition", service_task_definition.task_definition_arn)
    log("Containers", task_definition_helper.pretty_container_definitions)
    log("New task definition", new_task_definition.task_definition_arn)
    update_service(new_task_definition.task_definition_arn) && log("Update service", "Service task definition was updated")
    log("Waiting for deployment...")
    wait_for_deployment && log("Success", "Application was succesfully deployed", :cyan)
  end

  def update_service(task_definition_arn)
    helper.update_service(cluster_arn, service_arn, task_definition_arn)
  end

  def wait_for_deployment(time = 0)
    return true if service.deployments.count == 1
    error("Deployment timeout (#{timeout})") if time > timeout
    sleep STEP
    wait_for_deployment(time + STEP)
  end

  private

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
    (options[:timeout] || DEFAULT_TIMEOUT).to_i
  end

  def service
    helper.client.describe_service(cluster_arn, service_arn)
  end
end

require 'aws-sdk-ecs'
require 'aws-sdk-ecr'
require 'aws-sdk-ssm'

class ECSHelper::Client
  attr_accessor :ecs, :ecr, :ssm
  def initialize
    @ecs = Aws::ECS::Client.new
    @ecr = Aws::ECR::Client.new
    @ssm = Aws::SSM::Client.new
  end

  # ECS
  def task_definitions
    @task_definitions ||= ecs.list_task_definitions.task_definition_arns
  end

  def clusters
    @clusters ||= ecs.list_clusters.cluster_arns
  end

  def services(cluster)
    @services ||= ecs.list_services(cluster: cluster).service_arns
  end

  def tasks(cluster, service)
    arns = ecs.list_tasks(cluster: cluster, service_name: service).task_arns
    ecs.describe_tasks({ tasks: arns, cluster: cluster }).tasks
  end

  def describe_service(cluster, service)
    ecs.describe_services(cluster: cluster, services: [service]).services[0]
  end

  def describe_task_definition(task_definition)
    ecs.describe_task_definition(task_definition: task_definition).task_definition
  end

  def register_task_definition(params = {})
    ecs.register_task_definition(params).task_definition
  end

  def update_service(params = {})
    ecs.update_service(params)
  end

  def run_task(params = {})
    ecs.run_task(params).tasks[0]
  end

  def describe_tasks(params = {})
    ecs.describe_tasks(params).tasks
  end

  def list_tasks(params = {})
    ecs.list_tasks(params).task_arns
  end

  def execute_command(params = {})
    ecs.execute_command(params)
  end

  # ECR
  def private_repositories(params = {})
    ecr.describe_repositories(params).repositories
  end

  def describe_images(params = {})
    ecr.describe_images(params).image_details[0]
  end

  # SSM
  def get_ssm_parameters(params = {})
    ssm.get_parameters(params).parameters
  end
end

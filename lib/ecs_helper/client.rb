require 'aws-sdk-ecs'
require 'aws-sdk-ecr'
require 'aws-sdk-ecrpublic'

class ECSHelper::Client
  attr_accessor :ecs, :ecr, :ecr_public
  def initialize
    @ecs = Aws::ECS::Client.new
    @ecr = Aws::ECR::Client.new
    @ecr_public = Aws::ECRPublic::Client.new
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

  def deregister_task_definition(params = {})
    ecs.deregister_task_definition(params).task_definition
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

  # ECR
  def private_repositories(params = {})
    ecr.describe_repositories(params).repositories
  end

  def public_repositories(params = {})
    ecr_public.describe_repositories(params).repositories
  end

  def describe_images(params = {})
    ecr.describe_images(params).image_details[0]
  end
end

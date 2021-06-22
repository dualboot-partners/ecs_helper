require 'aws-sdk-ecs'

class ECSHelper::TaskDefinitionHelper
  attr_accessor :helper, :service, :service_task_definition, :repositories, :new_task_definition_hash
  def initialize(helper, service)
    @helper = helper
    @service = service
  end

  def service_task_definition
    @service_task_definition ||= helper.client.describe_task_definition(service.task_definition)
  end

  def container_definitions
    service_task_definition.container_definitions
  end

  def pretty_container_definitions
    container_definitions.map do |cd|
      repo, is_ecr, image, should_be_updated =  container_definition_to_ecr(cd)
      [
        cd.name,
        cd.image,
        is_ecr ? "ECR image" : "Not a ECR image",
        repo ? "Repo #{repo.repository_name}" : "Repo not found",
        image ? "Image version #{version}" : "Image version #{version} not found",
        should_be_updated ? "Will be updated" : "Not applicable"
      ].join(' | ')
    end.join("\n")
  end

  def register_task_definition(hash)
    helper.client.register_task_definition(hash)
  end

  def new_task_definition_hash
      attributes_to_remove = list = [:task_definition_arn, :revision, :status, :requires_attributes, :compatibilities, :registered_at, :registered_by]
      service_task_definition.to_hash
        .reject { |k,v| attributes_to_remove.include?(k.to_sym) }
        .merge(container_definitions: new_container_definitions)
  end

  def container_definition_to_ecr(cd)
    repo = repo_for(cd.name)
    is_ecr = cd.image.include?(ecr_base)
    image = repo && version_image(repo)
    should_update = is_ecr && repo && image
    [repo, is_ecr, image, should_update]
  end

  def new_container_definitions
    container_definitions.map do |cd|
      repo, is_ecr, image, should_be_updated =  container_definition_to_ecr(cd)
      cd.image = "#{repo.repository_uri}:#{version}" if should_be_updated
      cd.to_hash
    end
  end

  private

  def container_definition_to_ecr(cd)
    repo = repo_for(cd.name)
    is_ecr = cd.image.include?(ecr_base)
    image = repo && version_image(repo)
    should_update = is_ecr && repo && image
    [repo, is_ecr, image, should_update]
  end

  def repo_for(name)
    repositories.find do |r|
      uri = r.repository_uri
      uri.include?(helper.application) && uri.include?(helper.project) && uri.include?(name)
    end
  end

  def repositories
    @repositories ||= helper.client.private_repositories
  end

  def ecr_base
    repositories.first.repository_uri.split('/').first
  end

  def version_image(repo)
    client.describe_images({repository_name: repo.repository_name, image_ids: [image_tag: version]})
  rescue
    nil
  end

  def version
    helper.options[:version] || helper.version
  end
end
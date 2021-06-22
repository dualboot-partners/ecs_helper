require 'aws-sdk-ecs'

class ECSHelper::ServiceHelper
  attr_accessor :helper, :services, :cluster, :current_service

  def initialize(helper)
    @helper = helper
  end

  def services
    @services ||= helper.client.services(helper.current_cluster)
  end

  def current_service
    @current_service ||= from_options || only_one || from_env || raise(StandardError.new("Service not detected"))
  end

  def from_options
    value = helper.options[:service]
    return nil unless value
    return value if services.include?(value)
    raise(StandardError.new("Service specified in cli not exists, services you have: #{services}")) unless services.find {|r| r == value}
  end

  def from_env
    services.find {|s| s.include?(helper.application) && s.include?(helper.environment)}
  end

  def only_one
    return services[0] if services.length == 1
  end

  def update_service(cluster, service, task_definition)
    helper.client.update_service({
      cluster: cluster,
      service: service,
      task_definition: task_definition
    })
  end
end


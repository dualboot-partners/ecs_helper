require 'aws-sdk-ecs'

class ECSHelper::ClusterHelper
  attr_accessor :helper, :client, :clusters, :options, :project, :environment, :current_cluster
  def initialize(helper)
    @helper = helper
  end

  def clusters
    @clusters ||= helper.client.clusters
  end

  def current_cluster
    @current_cluster ||= from_options || only_one || from_env || raise(StandardError.new("Cluster not detected"))
  end

  def from_options
    value = helper.options[:cluster]
    return nil unless value
    return value if clusters.include?(value)
    raise(StandardError.new("Cluster specified in cli not exists, clusters you have: #{clusters}")) unless clusters.find {|r| r == value}
  end

  def from_env
    clusters.find {|c| c.include?(helper.project) && c.include?(helper.environment)}
  end

  def only_one
    return clusters[0] if clusters.length == 1
  end
end
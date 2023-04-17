require 'json'
require 'colorize'
require 'forwardable'

class ECSHelper
  extend Forwardable
  attr_accessor :options, :client, :command, :parser, :cluster_helper, :service_helper, :common_helper


  autoload :VERSION, 'ecs_helper/version'
  autoload :Client, 'ecs_helper/client'
  autoload :CommonHelper, 'ecs_helper/common_helper'
  autoload :ClusterHelper, 'ecs_helper/cluster_helper'
  autoload :ServiceHelper, 'ecs_helper/service_helper'
  autoload :TaskDefinitionHelper, 'ecs_helper/task_definition_helper'
  autoload :Error, 'ecs_helper/error'
  autoload :Command, 'ecs_helper/command'

  def_delegators :client, :task_definitions, :clusters, :services, :tasks, :repositories, :repositories, :task_definition, :run_task
  def_delegators :common_helper, :version, :branch, :environment, :project, :application, :region, :account_id, :auth_private_cmd
  def_delegators :cluster_helper, :current_cluster, :clusters
  def_delegators :service_helper, :current_service, :services, :update_service
  def_delegators :command, :run, :options, :type

  def initialize
    @client = Client.new
    @common_helper = CommonHelper.new(self)
    @cluster_helper = ClusterHelper.new(self)
    @service_helper = ServiceHelper.new(self)
    @command = Command.new(self)
  end
end

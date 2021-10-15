# frozen_string_literal: true

require 'terrapin'

class ECSHelper::Command::BuildAndPush < ECSHelper::Command::Base
  def cmd_option_parser
    options = { build_args: [] }
    parser = ::OptionParser.new do |opts|
      opts.banner = 'Usage: ecs_helper build_and_push [options]'
      opts.on('-i VALUE', '--image VALUE',
              'Set image name, will be used to detect ecr repo where to push image, for example web/nginx/toolbox (required)') do |c|
        options[:image] = processEqual(c)
      end
      opts.on('-d VALUE', '--directory VALUE', "Set directory for dockerfile and context, default = './'") do |c|
        options[:directory] = processEqual(c)
      end
      opts.on('-p VALUE', '--project VALUE',
              "Set project name, if not specified will look at ENV['PROJECT'], will be used to detect cluster") do |p|
        options[:project] = processEqual(p)
      end
      opts.on('-a VALUE', '--application VALUE',
              "Set application name, if not specified will look at ENV['APPLICATION'], will be used to detect service and task definition") do |a|
        options[:application] = processEqual(a)
      end
      opts.on('-c', '--cache', 'Cache image before build, default false') { options[:cache] = true }
      opts.on('--build-arg=VALUE', 'Pass --build-arg to the build command') { |o| options[:build_args] << o }
    end
    [parser, options]
  end

  def required
    [:image]
  end

  def run
    log("Command", type)
    log("Options", options)
    log("Repository", repository)
    log("Auth Private", auth_private)
    should_cache? && log("Pull", pull)
    log("Build", build)
    log("Push", push)
  end

  def auth_private
    auth_cmd = Terrapin::CommandLine.new('aws ecr get-login --no-include-email | sh')
    auth_cmd.run
  end

  def should_cache?
    options[:cache]
  end

  def pull
    pull_cmd = Terrapin::CommandLine.new("docker pull #{latest_tag}")
    pull_cmd.run
  rescue Terrapin::ExitStatusError => e
    console e.message
  end

  def build
    build_command = ["docker build #{directory}"]
    build_args = options[:build_args].map { |a| "--build-arg=#{a}" }
    cache_command = should_cache? ? ["--cache-from #{latest_tag}"] : []
    tags_command = ["--tag #{latest_tag} --tag #{version_tag}"]
    command = (build_command + build_args + cache_command + tags_command).join(' ')
    build_cmd = Terrapin::CommandLine.new(command)

    console "Building with two tags: #{latest_tag} & #{version_tag}"
    build_cmd.run
  end

  def push
    pull_cmd = Terrapin::CommandLine.new("docker push #{latest_tag} && docker push #{version_tag}")
    pull_cmd.run
  end

  private

  def image_name
    options[:image]
  end

  def directory
    options[:directory] || './'
  end

  def latest_tag
    "#{repository}:latest"
  end

  def version_tag
    "#{repository}:#{helper.version}"
  end

  def project
    helper.project
  end

  def application
    helper.application
  end

  def repository
    @repository ||= begin
      all = client.private_repositories

      with_name = all.select { |r| r.repository_arn.include?(image_name) }
      return with_name[0].repository_uri if with_name.length === 1

      exact = with_name.select { |r| r.repository_arn.include?(project) && r.repository_arn.include?(application) }
      return exact[0].repository_uri if exact.length === 1

      raise "Can't detect ECR repository"
    end
  end
end

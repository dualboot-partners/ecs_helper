module StubSupport
  def stub_auth()
    command_prefix = 'auth'
    command = "docker login -u AWS -p $(aws ecr get-login-password --region=#{AwsSupport.region}) #{AwsSupport.account_id}.dkr.ecr.#{AwsSupport.region}.amazonaws.com"
    command_state = states('command').starts_as("#{command_prefix}_new")
    result = "Success"
    Terrapin::CommandLine.any_instance.expects(:initialize).with(command).when(command_state.is(("#{command_prefix}_new"))).then(command_state.is("#{command_prefix}_initiated"))
    Terrapin::CommandLine.any_instance.expects(:run).returns(result)
  end

  def stub_pull(repo)
    command_prefix = 'pull'
    command_state = states('command').starts_as("#{command_prefix}_new")
    command = "docker pull #{repo}:latest"
    result = Terrapin::CommandLine::Output.new('success')
    Terrapin::CommandLine.any_instance.expects(:initialize).with(command).when(command_state.is(("#{command_prefix}_new"))).then(command_state.is("#{command_prefix}_initiated"))
    Terrapin::CommandLine.any_instance.expects(:run).returns(result)
  end

  def stub_build(repo, tag, options = {})
    command_prefix = 'build'
    command_state = states('command').starts_as("#{command_prefix}_new")
    command = "docker build #{options.fetch(:context, './')} --file #{options.fetch(:dockerfile, './Dockerfile')}"
    command << " --cache-from #{repo}:latest" if options[:cache]
    command << " --tag #{repo}:latest --tag #{repo}:#{tag}"
    result = Terrapin::CommandLine::Output.new('success')
    Terrapin::CommandLine.any_instance.expects(:initialize).with(command).when(command_state.is(("#{command_prefix}_new"))).then(command_state.is("#{command_prefix}_initiated"))
    Terrapin::CommandLine.any_instance.expects(:run).returns(result)
  end

  def stub_push(repo, tag)
    command_prefix = 'push'
    command_state = states('command').starts_as("#{command_prefix}_new")
    result = Terrapin::CommandLine::Output.new('success')
    command = "docker push #{repo}:latest && docker push #{repo}:#{tag}"
    result = "Success"
    Terrapin::CommandLine.any_instance.expects(:initialize).with(command).when(command_state.is(("#{command_prefix}_new"))).then(command_state.is("#{command_prefix}_initiated"))
    Terrapin::CommandLine.any_instance.expects(:run).returns(result)
  end

  def stub_repositories(repos)
    stub_responses = ::Aws.config[:ecr][:stub_responses] rescue {}
    stub_responses[:describe_repositories] = { repositories: repos }
    ::Aws.config[:ecr] = { stub_responses: stub_responses }
  end

  def stub_parameters(parameters)
    stub_responses = ::Aws.config[:ssm][:stub_responses] rescue {}
    stub_responses[:get_parameters] = { parameters: parameters }
    ::Aws.config[:ssm] = { stub_responses: stub_responses }
  end

  def stub_bin(bin, result = "Success")
    command_prefix = "#{bin}-bin"
    command_state = states('command').starts_as("#{command_prefix}_new")
    command = "which #{bin}"
    Terrapin::CommandLine.any_instance.expects(:initialize).with(command).when(command_state.is(("#{command_prefix}_new"))).then(command_state.is("#{command_prefix}_initiated"))
    Terrapin::CommandLine.any_instance.expects(:run).returns(result).when(command_state.is(("#{command_prefix}_initiated"))).then(command_state.is("#{command_prefix}_finished"))
  end

  def stub_aws_cli(version)
    versions = {
      v1: 'aws-cli/1.19.111 Python/3.8.10 Linux/4.19.121-linuxkit botocore/1.20.111',
      v2: 'aws-cli/2.2.4 Python/3.8.8 Linux/4.19.121-linuxkit docker/x86_64.amzn.2 prompt/off'
    }
    command_prefix = 'aws-cli'
    command_state = states('command').starts_as("#{command_prefix}_new")
    command = 'aws --version'
    result = versions[version]
    Terrapin::CommandLine.any_instance.expects(:initialize).with(command).when(command_state.is(("#{command_prefix}_new"))).then(command_state.is("#{command_prefix}_initiated"))
    Terrapin::CommandLine.any_instance.expects(:run).returns(result).when(command_state.is(("#{command_prefix}_initiated"))).then(command_state.is("#{command_prefix}_finished"))
  end

  def stub_check_ecs_exec(cluster_arn, task_arn, result = 'Success')
    command_prefix = 'check-ecs-exec'
    command_state = states('command').starts_as("#{command_prefix}_new")
    command = "#{command_prefix} #{cluster_arn} #{task_arn}"
    Terrapin::CommandLine.any_instance.expects(:initialize).with(command).when(command_state.is(("#{command_prefix}_new"))).then(command_state.is("#{command_prefix}_initiated"))
    Terrapin::CommandLine.any_instance.expects(:run).returns(result).when(command_state.is(("#{command_prefix}_initiated"))).then(command_state.is("#{command_prefix}_finished"))
  end

  def stub_clusters(clusters)
    stub_responses = ::Aws.config[:ecs][:stub_responses] rescue {}
    stub_responses[:list_clusters] = { cluster_arns: clusters }
    ::Aws.config[:ecs] = { stub_responses: stub_responses }
  end

  def stub_services(services)
    stub_responses = ::Aws.config[:ecs][:stub_responses] rescue {}
    stub_responses[:list_services] = { service_arns: services }
    ::Aws.config[:ecs] = { stub_responses: stub_responses }
  end

  def stub_list_tasks(tasks_arns)
    stub_responses = ::Aws.config[:ecs][:stub_responses] rescue {}
    stub_responses[:list_tasks] = { task_arns: tasks_arns }
    ::Aws.config[:ecs] = { stub_responses: stub_responses }
  end

  def stub_describe_task_definition(task_definition)
    stub_responses = ::Aws.config[:ecs][:stub_responses] rescue {}
    stub_responses[:describe_task_definition] = { task_definition: task_definition }
    ::Aws.config[:ecs] = { stub_responses: stub_responses }
  end

  def stub_describe_services(services)
    stub_responses = ::Aws.config[:ecs][:stub_responses] rescue {}
    stub_responses[:describe_services] = { services: services }
    ::Aws.config[:ecs] = { stub_responses: stub_responses }
  end
end

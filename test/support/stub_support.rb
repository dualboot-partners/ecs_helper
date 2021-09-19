module StubSupport
  def stub_auth
    Terrapin::CommandLine.any_instance.expects(:execute).with('aws ecr get-login --no-include-email | sh')
  end

  def stub_pull(repo)
    Terrapin::CommandLine.any_instance.expects(:execute).with("docker pull #{repo}:latest")
  end

  def stub_build(repo, tag, cache = true)
    command = cache ? "docker build ./ --cache-from #{repo}:latest --tag #{repo}:latest --tag #{repo}:#{tag}" :  "docker build ./ --tag #{repo}:latest --tag #{repo}:#{tag}"
    Terrapin::CommandLine.any_instance.expects(:execute).with(command)
  end

  def stub_push(repo, tag)
    Terrapin::CommandLine.any_instance.expects(:execute).with("docker push #{repo}:latest && docker push #{repo}:#{tag}")
  end

  def stub_terrapin
    Terrapin::CommandLine.any_instance.stubs(:run).returns(true)
  end

  def stub_repositories(repos)
    stub_responses = ::Aws.config[:ecr][:stub_responses] rescue {}
    stub_responses[:describe_repositories] = { repositories: repos }
    ::Aws.config[:ecr] = { stub_responses: stub_responses }
  end
end
module AwsSupport
  def region
    "us-west-2"
  end

  def account_id
    "012345678910"
  end

  def repository_arn(name)
    "arn:aws:ecr:#{region}:#{account_id}:repository/#{name}"
  end

  def repository_name(name)
    name
  end

  def repository_uri(name)
    "https://#{account_id}.dkr.ecr.#{region}.amazonaws.com/repository/#{name}"
  end

  def stub_private_repositories(setup)
    name1 = "web"
    name2 = "#{setup.project}-#{setup.application}-web"

    repo1 = { repository_arn: repository_arn(name1), repository_name: repository_name(name1), repository_uri: repository_uri(name1) }
    repo2 = { repository_arn: repository_arn(name2), repository_name: repository_name(name2), repository_uri: repository_uri(name2) }

    ::Aws.config[:ecr] = {
      stub_responses: {
        describe_repositories: { repositories: [ repo1, repo2 ] }
      }
    }
    return repo2
  end
end

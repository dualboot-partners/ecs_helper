require 'aws-sdk-ecs'
require 'aws-sdk-ecr'

class AwsSupport
  class << self

    def random_id(number)
      Array.new(number){[*"a".."z", *"0".."9"].sample}.join
    end

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

    def cluster_arn(project, env)
      "arn:aws:ecs:#{region}:#{account_id}:cluster/#{project}-cluster-#{env}"
    end

    def service_arn(project, application, env)
      "arn:aws:ecs:#{region}:#{account_id}:service/#{project}-cluster-#{env}/#{application}-service-#{env}"
    end

    def task_arn(project, env)
      "arn:aws:ecs:#{region}:#{account_id}:task/#{project}-cluster-#{env}/#{random_id(32)}"
    end

    def repository(name)
      {
        repository_arn: repository_arn(name),
        repository_name: repository_name(name),
        repository_uri: repository_uri(name)
      }
    end

    def parameter(name, value)
      {
        name: name,
        value: value
      }
    end
  end
end

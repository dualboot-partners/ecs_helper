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

    def container_instance_arn
      "arn:aws:ecr:#{region}:#{account_id}:container-instance/#{random_id(36)}"
    end

    def container_arn
      "arn:aws:ecr:#{region}:#{account_id}:container/#{random_id(36)}"
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

    def service_name(application, env)
      "#{application}-service-#{env}"
    end

    def service_arn(project, application, env)
      name = service_name(application, env)
      "arn:aws:ecs:#{region}:#{account_id}:service/#{project}-cluster-#{env}/#{name}"
    end

    def task_arn(project, env)
      "arn:aws:ecs:#{region}:#{account_id}:task/#{project}-cluster-#{env}/#{random_id(32)}"
    end

    def family
      'test-family'
    end

    def revision
      1
    end

    def task_definition_arn
      "arn:aws:ecs:#{region}:#{account_id}:task-definition/#{family}:#{revision}"
    end

    def task_definition(container_name)
      {
        container_definitions: [
          {
            name: container_name,
            essential: true,
            image: container_name,
            log_configuration: {
              log_driver: "awslogs",
              options: {
                "awslogs-group" => container_name,
                "awslogs-region" => region,
                "awslogs-stream-prefix" => container_name,
              },
            },
          }
        ],
        family: family,
        revision: revision,
        task_definition_arn: task_definition_arn,
        volumes: [],
      }
    end

    def task(project, env, container_name, status, exit_code)
      task_arn = task_arn(project, env)
      {
        container_instance_arn: container_instance_arn,
        containers: [
          {
            name: container_name,
            container_arn: container_arn,
            last_status: status,
            task_arn: task_arn,
            exit_code: exit_code,
          }
        ],
        desired_status: "RUNNING",
        last_status: status,
        task_arn: task_arn,
        task_definition_arn: task_definition_arn,
      }
    end

    def services(project, application, env, deployments_count)
      cluster_arn = cluster_arn(project, env)
      service_arn = service_arn(project, application, env)
      service_name = service_name(application, env)
      deployments = Array.new(deployments_count) do |i|
        {
          created_at: Time.parse("2016-08-29T16:25:52.130Z"),
          desired_count: 1,
          id: "ecs-svc/9223370564341623665",
          pending_count: 0,
          running_count: 0,
          status: "PRIMARY",
          task_definition: "arn:aws:ecs:us-east-1:012345678910:task-definition/hello_world:6",
          updated_at: Time.parse("2016-08-29T16:25:52.130Z"),
        }
      end

      [
        {
          cluster_arn: cluster_arn,
          deployments: deployments,
          desired_count: 1,
          pending_count: 0,
          running_count: 0,
          service_arn: service_arn,
          service_name: service_name,
          status: "ACTIVE",
          task_definition: task_definition_arn,
          network_configuration: {
            awsvpc_configuration: {
              subnets: ["test"], # required
              security_groups: [],
              assign_public_ip: "DISABLED"
            },
          }
        },
      ]
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

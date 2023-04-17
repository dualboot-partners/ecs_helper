# ECS Helper - A tool for managing the deployment process of an application in Amazon Elastic Container Service (ECS)

## Introduction

ECS Helper is a command-line tool written in Ruby that allows you to control the deployment process of your application
in Amazon Elastic Container Service. The tool provides various commands for building and pushing images, deploying your
application, exporting images, logging in to Amazon Elastic Container Registry (ECR), running commands, exporting
environment variables, and more. To use it an ECS Cluster with a service running there and have task_definitons is
required. Docker images are stored in the ECR Elastic Container Registry.

## Installation

### Ruby Gem

To use ECS Helper, you need to install the ecs_helper gem. You can install it using the following command:

```bash
gem install ecs_helper
```

You can use the ecs_helper command followed by the desired command and arguments to control your application deployment
process.

### Docker Image

Alternatively, you can use the Docker image `partos/ecs_toolbox`. This image contains the ecs_helper gem and the AWS CLI
tool. You can use the image to run the ecs_helper command in a container.

## The available commands are:

- **build_and_push**: builds and pushes the Docker image to Amazon Elastic Container Registry (ECR).
- **deploy**: deploys the Docker image to Amazon Elastic Container Service (ECS).
- **export_images**: exports Docker images to a file.
- **ecr_login**: logs in to Amazon Elastic Container Registry (ECR).
- **run_command**: runs a command in a container.
- **export_env_secrets**: exports environment variables to a file.
- **exec**: executes a command in a running container.
- **check_exec**: checks if the command in the running container was executed successfully.

You can select the desired command by passing the argument to the ecs_helper command. For example, to build and push an
image with the tag api, you can use the following command:

```bash
ecs_helper build_and_push --image=api
```

## Using in GitLab CI

ECS Helper can also be used in GitLab CI by using a pre-built Docker image. Here's an example of how to use ECS Helper
in a GitLab CI pipeline:

```yaml
stages:
  - build
  - deploy


variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ''
  DOCKER_IMAGE: docker:20.10.6
  PROJECT: test_project
  TOOLBOX_IMAGE: partos/ecs_toolbox:0.0.34
  AWS_REGION: us-east-1
  AWS_DEFAULT_REGION: us-east-1
  APPLICATION: app

.ci_deploy: &ci_deploy

only:
  - master
  - staging

build_app:
  <<: *ci_deploy
  stage: build
  image: $TOOLBOX_IMAGE
  script:
    - mkdir -p ./apps/api/dist/apps && cp -r ./dist/apps/api ./apps/api/dist/apps
    - ecs_helper build_and_push --image=api --cache -d ./apps/api

deploy_app:
  <<: *ci_deploy
  stage: deploy
  image: $TOOLBOX_IMAGE
  variables:
  APPLICATION: app
  script:
    - ecs_helper deploy --timeout 600
```

In this example, ECS Helper is used to build and push the api Docker image in the build_app job, and to deploy the
application in the deploy_app job.

When a new version of an application is deployed, a new task definition revision is created in the target service.

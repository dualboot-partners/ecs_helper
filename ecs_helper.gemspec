Gem::Specification.new do |s|
  s.name        = 'ecs_helper'
  s.version     = '0.0.20'
  s.summary     = "ECSHelper"
  s.description = "A simple gem which make CI CD process easier for AWS ECS service"
  s.authors     = ["Artem Petrov"]
  s.email       = 'artem.petrov@dualbootpartners.com'
  s.files       = Dir['lib/**/*.rb']
  s.bindir      = 'bin'
  s.executables << 'ecs_helper'
  s.homepage    = 'https://github.com/artempartos/ecs_helper'
  s.license     = 'MIT'

  s.add_runtime_dependency 'aws-sdk-ecs', '~> 1.80', '>= 1.80'
  s.add_runtime_dependency 'aws-sdk-ecr', '~> 1.42', '>= 1.42'
  s.add_runtime_dependency 'aws-sdk-ecrpublic', '~> 1.3', '>= 1.3'
  s.add_runtime_dependency 'json', '~> 2.5', '>= 2.5'
  s.add_runtime_dependency 'colorize', '~> 0.8', '>= 0.8'
  s.add_runtime_dependency 'terrapin', '~> 0.6', '>= 0.6'
end


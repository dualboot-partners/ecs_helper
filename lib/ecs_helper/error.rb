# frozen_string_literal: true

class ECSHelper::Error
  autoload :Base, 'ecs_helper/error/base'
  autoload :CommandNotFound, 'ecs_helper/error/command_not_found'
end

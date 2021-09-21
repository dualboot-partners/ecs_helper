# frozen_string_literal: true

class ECSHelper::Error
  autoload :Base, 'ecs_helper/error/base'
  autoload :CommandNotFound, 'ecs_helper/error/command_not_found'
  autoload :CommandValidationError, 'ecs_helper/error/command_validation_error'
  autoload :BinNotFound, 'ecs_helper/error/bin_not_found'
end

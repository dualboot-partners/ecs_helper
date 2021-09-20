# frozen_string_literal: true

require 'test_helper'

require 'aws-sdk-ecs'
require 'aws-sdk-ecr'

class ECSHelper::Command::ExportEnvSecretsTest < Minitest::Test
  def test_export_env_secrets_with_no_vars
    command = 'export_env_secrets'

    with_command(command) do |setup|
      helper = ECSHelper.new
      export_string = helper.run
      assert export_string == nil
    end
  end

  def test_export_env_secrets
    env_vars = {
      TEST_VAR: "test_value_1",
      TEST_VAR_2: 'test_value_2',
    }
    command = "export_env_secrets -n #{env_vars.keys.join(' -n ')}"

    with_command(command) do |setup|
      prepare_data(setup, env_vars)
      helper = ECSHelper.new
      export_string = helper.run
      assert (export_string =~ /^export/)

      env_vars.keys.each do |key|
        assert (export_string =~ /#{key}=#{env_vars[key]}/)
      end
    end
  end

  def prepare_data(setup, env_vars)
    prefix = "/#{setup.project}-#{setup.application}-#{setup.environment}/"
    parameters = env_vars.keys.map { |key| AwsSupport.parameter(prefix + key.to_s, env_vars[key]) }
    stub_parameters(parameters)
  end
end

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
    env_vars = ["TEST_VAR", 'TEST_VAR_2']
    value = "secret_value"
    command = "export_env_secrets -n #{env_vars.join(' -n ')}"

    env_vars.each do |env_var|
      aws_param_name = "/#{env_prefix}/#{env_var}"
      stub_request(:post, "https://ssm.us-west-2.amazonaws.com/")
        .with( body: "{\"Name\":\"#{aws_param_name}\",\"WithDecryption\":true}")
        .to_return(status: 200, body: "{
          \"Parameter\": {
            \"Name\": \"#{aws_param_name}\",
            \"Type\": \"SecureString\",
            \"Value\": \"#{value}\",
            \"Version\": 1,
            \"LastModifiedDate\": 1631627712.215,
            \"ARN\": \"arn:aws:ssm:us-west-2:520593055087:parameter#{aws_param_name}\",
            \"DataType\": \"text\"
            }
          }", headers: { content_type: 'application/json'})
    end

    with_command(command) do |setup|
      helper = ECSHelper.new
      export_string = helper.run
      assert (export_string =~ /^export/)

      env_vars.each do |var|
        assert (export_string =~ /#{var}=#{value}/)
      end
    end
  end
end


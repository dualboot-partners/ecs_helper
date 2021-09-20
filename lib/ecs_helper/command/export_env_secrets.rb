require 'terrapin'

class ECSHelper::Command::ExportEnvSecrets < ECSHelper::Command::Base
  attr_accessor :params

  def cmd_option_parser
    options = {
      env_vars: []
    }
    parser = ::OptionParser.new do |opts|
      opts.banner = "Usage: ecs_helper export_env_secrets"
      opts.on('-n', '--name=VARIABLE', '') { |o| options[:env_vars] << o }
    end
    [parser, options]
  end

  def required
    []
  end

  def run
    return log("No ENV secrets to export. Please pass ENV variables names using -n") if options[:env_vars].empty?
    export_values
  end

  private

  def to_aws_ssm_name(name)
    "/#{helper.project}-#{helper.application}-#{helper.environment}/#{name}"
  end

  def export_values
    params_name = options[:env_vars].map {|var_name| to_aws_ssm_name(var_name)}
    aws_ssm_params = client.get_ssm_parameters(names: params_name, with_decryption: true)

    variables = (['export'] + aws_ssm_params.map do |aws_ssm_param|
      next if aws_ssm_param.empty?
      value = aws_ssm_param.value
      name = aws_ssm_param.name.split('/').last

      "#{name}=#{value}"
    rescue Aws::SSM::Errors::ParameterNotFound
      next
    end).join(' ')
  end
end

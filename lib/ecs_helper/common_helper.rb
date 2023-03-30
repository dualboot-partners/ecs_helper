BRANCH_TO_ENV_MAPPING = {
  master: 'production',
  main: 'production',
  qa: 'qa',
  uat: 'uat',
  staging: 'staging',
  demo: 'demo',
}

class ECSHelper::CommonHelper
  attr_accessor :helper, :branch, :version, :env, :region, :account_id

  def initialize(helper)
    @helper = helper
  end

  def branch
    @branch ||= ENV["CI_COMMIT_BRANCH"] || `git rev-parse --abbrev-ref HEAD`.strip
  end

  def version
    @version ||=
      begin
        if use_image_tag_env_prefix?
          "#{environment}-#{commit_sha}"
        elsif !custom_image_tag.nil? && !custom_image_tag.delete(' ').empty?
          "#{custom_image_tag}-#{commit_sha}"
        else
          commit_sha
        end
      end
  end

  def environment
    @env ||= helper.options[:environment] || ENV["ENVIRONMENT"] || env_from_branch || raise(StandardError.new("Environment not detected"))
  end

  def project
    ENV["PROJECT"]
  end

  def application
    ENV["APPLICATION"]
  end

  def region
    @region ||= ENV["AWS_REGION"]
  end

  def account_id
    @account_id||= ENV["AWS_ACCOUNT_ID"] || `aws sts get-caller-identity --query "Account" --output text`.strip
  end

  private

  def env_from_branch
    BRANCH_TO_ENV_MAPPING[branch.to_sym]
  end

  def deployable_branch?
    !env_from_branch.nil?
  end

  def commit_sha
    ENV["CI_COMMIT_SHA"] || `git rev-parse HEAD`.strip
  end

  def use_image_tag_env_prefix?
    !ENV['USE_IMAGE_TAG_ENV_PREFIX'].nil?
  end

  def custom_image_tag
    ENV['CUSTOM_IMAGE_TAG']
  end

end

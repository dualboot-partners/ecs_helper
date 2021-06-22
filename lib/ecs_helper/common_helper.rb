BRANCH_TO_ENV_MAPPING = {
  master: 'production',
  qa: 'qa',
  staging: 'staging',
  demo: 'demo',
}

class ECSHelper::CommonHelper
  attr_accessor :helper, :branch, :version, :env
  def initialize(helper)
    @helper = helper
  end

  def branch
    @branch ||= ENV["CI_COMMIT_BRANCH"] || `git rev-parse --abbrev-ref HEAD`.strip
  end

  def version
    @version ||= ENV["CI_COMMIT_SHA"] || `git rev-parse HEAD`.strip
  end

  def environment
    @env ||= helper.options[:environment] || ENV["ENVIRONMENT"] || BRANCH_TO_ENV_MAPPING[branch.to_sym] || raise(StandardError.new("Environment not detected"))
  end

  def project
    ENV["PROJECT"]
  end

  def application
    ENV["APPLICATION"]
  end
end
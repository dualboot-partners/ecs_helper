require 'terrapin'

class ECSHelper::Command::ExportImages < ECSHelper::Command::Base

  def cmd_option_parser
    options = {}
    parser = ::OptionParser.new do |opts|
      opts.banner = "Usage: ecs_helper export_images"
    end
    [parser, options]
  end

  def required
    []
  end

  def printable?
    true
  end

  def run
    export_images
  end

  private

  def project
    helper.project
  end

  def application
    helper.application
  end

  def export_images
    variables = (['export'] + client.private_repositories.map do |repo|
      container_name = repo.repository_name.scan(/#{project}-#{application}-(.*)/).flatten.first
      next if container_name.nil?
      key = container_name.upcase.gsub("-", "_") + "_IMAGE"
      value = "#{repo.repository_uri}:#{helper.version}"
      "#{key}=#{value}"
    end).join(' ')
    variables
  end
end

module AwsSupport
  def region
    "us-west-2"
  end

  def account_id
    "012345678910"
  end

  def repository_arn(name)
    "arn:aws:ecr:#{region}:#{account_id}:repository/#{name}"
  end

  def repository_name(name)
    name
  end

  def repository_uri(name)
    "https://#{account_id}.dkr.ecr.#{region}.amazonaws.com/repository/#{name}"
  end
end
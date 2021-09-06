class ECSHelper::Error::Base < StandardError
  def initialize(builder)
    @builder = builder
  end

  def message
    return @builder.join("\n") if @builder
    "Failed"
  end
end
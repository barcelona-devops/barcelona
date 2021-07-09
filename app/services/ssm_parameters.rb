class SsmParameters
  def initialize(district, name)
    @district = district
    @name = name
  end

  def put_parameter(value)
    client.put_parameter({
                           name: ssm_path, # required
                           value: value, # required
                           type: "SecureString"
                         })
  end

  def delete_parameter
    client.delete_parameters({
                               names: [ssm_path]
                             })
  end

  def get_parameters(ssm_paths)
    client.get_parameters({
                            names: ssm_paths
                          })
  end

  def ssm_path
    "/barcelona/#{@district.name}/#{@name}"
  end

  private

  def client
    @client ||= @district.aws.ssm
  end
end

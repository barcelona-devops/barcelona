class AwsAccessor
  attr_accessor :district
  def initialize(district)
    @district = district
  end

  def ecs
    @ecs ||= Aws::ECS::Client.new(client_config)
  end

  def s3
    @s3 ||= Aws::S3::Client.new(client_config)
  end

  def ec2
    @ec2 ||= Aws::EC2::Client.new(client_config)
  end

  def elb
    @elb ||= Aws::ElasticLoadBalancing::Client.new(client_config)
  end

  def route53
    @route53 ||= Aws::Route53::Client.new(client_config)
  end

  def cloudformation
    @cloudformation ||= Aws::CloudFormation::Client.new(client_config)
  end

  def sns
    @sns ||= Aws::SNS::Client.new(client_config)
  end

  def autoscaling
    @autoscaling ||= Aws::AutoScaling::Client.new(client_config)
  end

  def ssm
    @ssm ||= Aws::SSM::Client.new(client_config)
  end

  def ecr(image_name)
    if public_ecr?(image_name)
      public_ecr
    else
      private_ecr
    end
  end

  private

  def client_config
    {region: district.region, credentials: credentials}
  end

  def credentials
    if district.aws_role.present?
      Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new(region: district.region),
        role_arn: district.aws_role,
        role_session_name: "barcelona-#{district.name}-session-#{Time.now.to_i}",
        duration_seconds: 3600
      )
    else
      Aws::Credentials.new(district.aws_access_key_id, district.aws_secret_access_key)
    end
  end

  def private_ecr
    @private_ecr ||= Aws::ECR::Client.new(client_config)
  end

  def public_ecr
    @public_ecr ||= Aws::ECRPublic::Client.new({region: "us-east-1", credentials: credentials})
  end

  def public_ecr?(image_name)
    image_name.match(/^public\.ecr\.aws/)
  end
end

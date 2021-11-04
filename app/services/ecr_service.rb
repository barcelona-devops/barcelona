class EcrService
  def initialize(heritage)
    @heritage = heritage
  end

  def validate_image!
    begin
      response = ecr.describe_images({
                                       image_ids: [
                                         {
                                           image_tag: @heritage.tag
                                         }
                                       ],
                                       repository_name: repository_name
                                     })
    rescue Aws::ECR::Errors::RepositoryNotFoundException,
           Aws::ECRPublic::Errors::RepositoryNotFoundException
      raise ExceptionHandler::BadRequest.new("Image not found in ECR: #{@heritage.image_path}")
    rescue Aws::ECR::Errors::ImageNotFoundException,
           Aws::ECRPublic::Errors::ImageNotFoundException
      raise ExceptionHandler::BadRequest.new("Image tag not found in ECR: #{@heritage.image_path}")
    end
  end

  private

  def ecr
    @ecr ||= if public_ecr?
               ecr_public
             else
               ecr_private
             end
  end

  def ecr_public
    @heritage.district.aws.public_ecr
  end

  def ecr_private
    @heritage.district.aws.ecr
  end

  def public_ecr?
    @heritage.image_name.match(/^public\.ecr\.aws/)
  end

  # The string after the last / will be matched.
  # For example, when the Image name is public.ecr.aws/degica/barcelona,
  # it will return barcelona.
  def repository_name
    @heritage.image_name[%r{/([^/]*?)$}, 1]
  end
end

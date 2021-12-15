require "rails_helper"

describe SsmParameters do
  let(:district) { build :district, name: 'district_name', aws_access_key_id: 'test', aws_secret_access_key: 'test' }
  let(:name) { district.name }

  describe "#ssm_path" do
    it "returns expected ssm_path" do
      expect(described_class.new(district, 'app/param_name').ssm_path).to eq "/barcelona/district_name/app/param_name"
    end
  end

  describe "#put_parameter" do
    let(:parameter_value) { "test123"}

    it "put ssm parameters" do
      expect_any_instance_of(Aws::SSM::Client).to receive(:put_parameter).with(name: "/barcelona/district_name/district_name", # required
                                                                               value: "test123",
                                                                               type: "SecureString",
                                                                               overwrite: true).and_call_original

      response = described_class.new(district, name).put_parameter(parameter_value)
      expect(response.version).to eq 0
    end
  end

  describe "#delete_parameter" do
    it "delete ssm parameter" do
      ssm_parameters = described_class.new(district, name)
      expect_any_instance_of(Aws::SSM::Client).to receive(:delete_parameters).
        with(names: [ssm_parameters.ssm_path]).and_call_original

      response = ssm_parameters.delete_parameter
      expect(response.deleted_parameters).to eq []
      expect(response.invalid_parameters).to eq []
    end
  end

  describe "#get_invalids_parameters" do
    it "get invalid parameter" do
      ssm_parameters = described_class.new(district, "")
      ssm_paths = [
        "/barcelona/test/path/to/secret-1",
        "/barcelona/test/path/to/secret-2"
      ]

      expect_any_instance_of(Aws::SSM::Client).to receive(:get_parameters).
        with(names: ssm_paths).and_call_original

      invalid_parameters = ssm_parameters.get_invalid_parameters(ssm_paths)
      expect(invalid_parameters).to eq []
    end

    it "return empty when ssm path is empty" do
      ssm_parameters = described_class.new(district, "")
      ssm_paths = []

      expect_any_instance_of(Aws::SSM::Client).not_to receive(:get_parameters).
        with(names: ssm_paths)

      invalid_parameters = ssm_parameters.get_invalid_parameters(ssm_paths)
      expect(invalid_parameters).to eq []
    end

    it "throw UnprocessableEntity error" do
      ssm_parameters = described_class.new(district, "")
      ssm_paths = [
        "/barcelona/test/path/to/secret-1"
      ]

      allow_any_instance_of(Aws::SSM::Client).to receive(:get_parameters).and_raise(StandardError)
      expect { ssm_parameters.get_invalid_parameters(ssm_paths) }.to raise_error(ExceptionHandler::UnprocessableEntity)
    end

    it "throw an error when ssm_paths are more than 10" do
      ssm_parameters = described_class.new(district, "")

      ssm_paths = []

      (0..10).each do |i|
        ssm_paths << "/barcelona/test/path/to/secret-#{i}"
      end

      expect_any_instance_of(Aws::SSM::Client).not_to receive(:get_parameters)
      expect { ssm_parameters.get_invalid_parameters(ssm_paths) }.to raise_error(ExceptionHandler::UnprocessableEntity)
    end
  end
end

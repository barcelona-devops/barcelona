require 'rails_helper'

describe "PATCH /districts/:district/endpoints/:endpoint", type: :request do
  let(:user) { create :user }
  let(:district) { create :district }

  let(:params) do
    {
      certificate_id: "test_certificate_id",
      ssl_policy: "old"
    }
  end

  given_auth(GithubAuth) do
    before do
      allow_any_instance_of(CloudFormation::Executor).to receive(:outputs) {
        {"DNSName" => "dns.name"}
      }
    end

    it "update endpoint" do
      district.endpoints.create(name: "ep1")
      endpoint = district.endpoints.first

      api_request(:patch, "/v1/districts/#{district.name}/endpoints/#{endpoint.name}", params)

      endpoint.reload
      expect(response.status).to eq 200
      expect(endpoint.certificate_id).to eq "test_certificate_id"
      expect(endpoint.ssl_policy).to eq "old"
      expect(endpoint.name).to eq "ep1"
    end

    it "update district-endpoint" do
      district.endpoints.create(name: "#{district.name}-ep1")
      endpoint = district.endpoints.first

      api_request(:patch, "/v1/districts/#{district.name}/endpoints/ep1", params)

      endpoint.reload
      expect(response.status).to eq 200
      expect(endpoint.certificate_id).to eq "test_certificate_id"
      expect(endpoint.ssl_policy).to eq "old"
      expect(endpoint.name).to eq "#{district.name}-ep1"
    end

    it "throw error if there is a existing same name endpoint" do
      params = {
        name: "bar",
        public: true,
        ssl_policy: 'modern',
        certificate_id: 'certificate_id'
      }

      district = create :district, name: "food"
      district.endpoints.create(name: "food-bar")

      api_request(:post, "/v1/districts/#{district.name}/endpoints", params)

      expect(response.status).to eq 422
    end
  end
end

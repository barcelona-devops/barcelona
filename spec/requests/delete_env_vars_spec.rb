require 'rails_helper'

describe "DELETE /heritages/:heritage/env_vars", type: :request do
  let(:user) { create :user }
  let(:district) { create :district }

  given_auth(GithubAuth) do
    before {Aws.config[:stub_responses] = true}
    before do
      params = {
        name: "nginx",
        image_name: "nginx",
        image_tag: "latest",
        before_deploy: "echo hello",
        services: [
          {
            name: "web",
            public: true,
            cpu: 128,
            memory: 256,
            command: "nginx",
            port_mappings: [
              {
                lb_port: 80,
                container_port: 80
              }
            ]
          }
        ]
      }
      api_request :post, "/v1/districts/#{district.name}/heritages", params
      expect(response).to be_successful
      api_request :post, "/v1/heritages/nginx/env_vars", {env_vars: {"RAILS_ENV" => "production"}}
      expect(response).to be_successful
    end

    it "deletes heritage's environment variables" do
      params = {
        env_keys: ["RAILS_ENV"]
      }

      expect(DeployRunnerJob).to receive(:perform_later)
      api_request :delete, "/v1/heritages/nginx/env_vars", params
      expect(response).to be_successful

      heritage = JSON.load(response.body)["heritage"]
      expect(heritage["name"]).to eq "nginx"
      expect(heritage["image_name"]).to eq "nginx"
      expect(heritage["image_tag"]).to eq "latest"
      expect(heritage["before_deploy"]).to eq "echo hello"
      expect(heritage["services"][0]["name"]).to eq "web"
      expect(heritage["services"][0]["public"]).to eq true
      expect(heritage["services"][0]["cpu"]).to eq 128
      expect(heritage["services"][0]["memory"]).to eq 256
      expect(heritage["services"][0]["command"]).to eq "nginx"
      expect(heritage["services"][0]["port_mappings"][0]["lb_port"]).to eq 80
      expect(heritage["services"][0]["port_mappings"][0]["container_port"]).to eq 80

      expect(heritage["env_vars"]).to be_blank
    end
  end
end

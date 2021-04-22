require "rails_helper"

describe GithubAuth do
  describe ".login" do
    let(:auth) { GithubAuth.new(request) }
    let(:request) do
      double(
        headers: {
          "HTTP_X_GITHUB_TOKEN" => "github-token"
        },
        params: {
        }
      )
    end
    subject { auth.login }

    let(:github_client) do
      double(user_teams: github_teams, user: double(login: "k2nr"))
    end

    context "when teams are specified" do
      before do
        allow(Octokit::Client).to receive(:new) { github_client }
        stub_env('GITHUB_ORGANIZATION', 'degica')
        stub_env('GITHUB_DEVELOPER_TEAM', 'developers')
        stub_env('GITHUB_ADMIN_TEAM', 'Admin developers')
      end

      context "when a user belongs to a github admin team" do
        let(:github_teams) do
          [
            double(name: "Admin developers", organization: double(login: "degica"))
          ]
        end
        its(:roles) { is_expected.to eq ["admin"] }
        its(:token) { is_expected.to be_present }
      end

      context "when a user belongs to a github developers team" do
        let(:github_teams) do
          [
            double(name: "developers", organization: double(login: "degica"))
          ]
        end
        its(:roles) { is_expected.to eq ["developer"] }
        its(:token) { is_expected.to be_present }
      end

      context "when a user doesn't belong to allowed github teams" do
        let(:github_teams) do
          [
            double(name: "reviewers", organization: double(login: "degica"))
          ]
        end
        it { is_expected.to be_nil }
      end

      context "when a user doesn't belong to the organization" do
        let(:github_teams) do
          [
            double(name: "Admin developers", organization: double(login: "other_org"))
          ]
        end

        it { is_expected.to be_nil }
      end
    end

    context "when teams are not specified" do
      before do
        allow(Octokit::Client).to receive(:new) { github_client }
        stub_env('GITHUB_ORGANIZATION', 'degica')
        stub_env('GITHUB_DEVELOPER_TEAM', nil)
        stub_env('GITHUB_ADMIN_TEAM', nil)
      end

      let(:github_teams) do
        [
          double(name: "reviewers",  organization: double(login: "degica")),
          double(name: "developers", organization: double(login: "degica"))
        ]
      end

      its(:roles) { is_expected.to eq ["developer", "admin"] }
      its(:token) { is_expected.to be_present }

      context "when a user doesn't belong to the organization" do
        let(:github_teams) do
          [
            double(name: "Admin developers", organization: double(login: "other_org"))
          ]
        end

        it { is_expected.to be_nil }
      end

      context "pick the correct user even if the user already exists in deferent auth" do
        before do
          vault_user = User.create!(
            name: 'someuniquename',
            auth: 'vault',
            token: 'defg',
            roles: []
          )

          vault_user = User.create!(
            name: 'someuniquename',
            auth: 'github',
            token: 'token',
            roles: []
          )
        end

        its(:auth) { is_expected.to eq nil }
        its(:token) { is_expected.to be_present }
      end
    end
  end
end

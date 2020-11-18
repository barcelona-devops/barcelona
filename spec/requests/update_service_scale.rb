require 'rails_helper'

describe "updating a heritage" do
  let(:user) { create :user }

  before do
    allow_any_instance_of(ApplicationController).to receive(:authenticate)
    allow_any_instance_of(ApplicationController).to receive(:authorize_action)
  end

  describe "POST /heritages/:heritage/services/:service_name/count", type: :request do
    it 'adds the container count' do
      district = create :district
      heritage = create :heritage, district: district
      service = create :service, name: 'serv', heritage: heritage, desired_container_count: nil

      params = {
        desired_container_count: 10
      }

      expect_any_instance_of(Heritage).to receive(:save_and_deploy!).and_call_original

      api_request :post, "/v1/districts/#{district.name}/heritages/#{heritage.name}/services/serv/count", params

      expect(Service.last.desired_container_count).to eq 10
    end

    it 'changes the container count' do
      district = create :district
      heritage = create :heritage, district: district
      service = create :service, name: 'serv', heritage: heritage, desired_container_count: 11

      params = {
        desired_container_count: 15
      }

      expect_any_instance_of(Heritage).to receive(:save_and_deploy!).and_call_original

      api_request :post, "/v1/districts/#{district.name}/heritages/#{heritage.name}/services/serv/count", params

      expect(Service.last.desired_container_count).to eq 15
    end
  end
end

require 'rails_helper'

RSpec.describe SseController, :type => :controller do

  describe "GET feedback_send" do
    it "returns http success" do
      get :feedback_send
      expect(response).to have_http_status(:success)
    end
  end

end

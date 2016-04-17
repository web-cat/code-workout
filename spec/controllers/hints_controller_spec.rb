require 'rails_helper'

RSpec.describe HintsController, :type => :controller do

  describe "GET approve_hint" do
    it "returns http success" do
      get :approve_hint
      expect(response).to have_http_status(:success)
    end
  end

end

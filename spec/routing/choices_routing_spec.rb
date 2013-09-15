require "spec_helper"

describe ChoicesController do
  describe "routing" do

    it "routes to #index" do
      get("/choices").should route_to("choices#index")
    end

    it "routes to #new" do
      get("/choices/new").should route_to("choices#new")
    end

    it "routes to #show" do
      get("/choices/1").should route_to("choices#show", :id => "1")
    end

    it "routes to #edit" do
      get("/choices/1/edit").should route_to("choices#edit", :id => "1")
    end

    it "routes to #create" do
      post("/choices").should route_to("choices#create")
    end

    it "routes to #update" do
      put("/choices/1").should route_to("choices#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/choices/1").should route_to("choices#destroy", :id => "1")
    end

  end
end

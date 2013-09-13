require "spec_helper"

describe TermsController do
  describe "routing" do

    it "routes to #index" do
      get("/terms").should route_to("terms#index")
    end

    it "routes to #new" do
      get("/terms/new").should route_to("terms#new")
    end

    it "routes to #show" do
      get("/terms/1").should route_to("terms#show", :id => "1")
    end

    it "routes to #edit" do
      get("/terms/1/edit").should route_to("terms#edit", :id => "1")
    end

    it "routes to #create" do
      post("/terms").should route_to("terms#create")
    end

    it "routes to #update" do
      put("/terms/1").should route_to("terms#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/terms/1").should route_to("terms#destroy", :id => "1")
    end

  end
end

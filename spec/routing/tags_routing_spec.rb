require "spec_helper"

describe TagsController do
  describe "routing" do

    it "routes to #index" do
      get("/tags").should route_to("tags#index")
    end

    it "routes to #new" do
      get("/tags/new").should route_to("tags#new")
    end

    it "routes to #show" do
      get("/tags/1").should route_to("tags#show", :id => "1")
    end

    it "routes to #edit" do
      get("/tags/1/edit").should route_to("tags#edit", :id => "1")
    end

    it "routes to #create" do
      post("/tags").should route_to("tags#create")
    end

    it "routes to #update" do
      put("/tags/1").should route_to("tags#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/tags/1").should route_to("tags#destroy", :id => "1")
    end

  end
end

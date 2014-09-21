require "spec_helper"

describe ResourceFilesController do
  describe "routing" do

    it "routes to #index" do
      get("/resource_files").should route_to("resource_files#index")
    end

    it "routes to #new" do
      get("/resource_files/new").should route_to("resource_files#new")
    end

    it "routes to #show" do
      get("/resource_files/1").should route_to("resource_files#show", :id => "1")
    end

    it "routes to #edit" do
      get("/resource_files/1/edit").should route_to("resource_files#edit", :id => "1")
    end

    it "routes to #create" do
      post("/resource_files").should route_to("resource_files#create")
    end

    it "routes to #update" do
      put("/resource_files/1").should route_to("resource_files#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/resource_files/1").should route_to("resource_files#destroy", :id => "1")
    end

  end
end

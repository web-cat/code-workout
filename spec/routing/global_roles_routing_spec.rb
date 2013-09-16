require "spec_helper"

describe GlobalRolesController do
  describe "routing" do

    it "routes to #index" do
      get("/global_roles").should route_to("global_roles#index")
    end

    it "routes to #new" do
      get("/global_roles/new").should route_to("global_roles#new")
    end

    it "routes to #show" do
      get("/global_roles/1").should route_to("global_roles#show", :id => "1")
    end

    it "routes to #edit" do
      get("/global_roles/1/edit").should route_to("global_roles#edit", :id => "1")
    end

    it "routes to #create" do
      post("/global_roles").should route_to("global_roles#create")
    end

    it "routes to #update" do
      put("/global_roles/1").should route_to("global_roles#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/global_roles/1").should route_to("global_roles#destroy", :id => "1")
    end

  end
end

require "spec_helper"

describe StemsController do
  describe "routing" do

    it "routes to #index" do
      get("/stems").should route_to("stems#index")
    end

    it "routes to #new" do
      get("/stems/new").should route_to("stems#new")
    end

    it "routes to #show" do
      get("/stems/1").should route_to("stems#show", :id => "1")
    end

    it "routes to #edit" do
      get("/stems/1/edit").should route_to("stems#edit", :id => "1")
    end

    it "routes to #create" do
      post("/stems").should route_to("stems#create")
    end

    it "routes to #update" do
      put("/stems/1").should route_to("stems#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/stems/1").should route_to("stems#destroy", :id => "1")
    end

  end
end

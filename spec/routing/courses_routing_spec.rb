require "spec_helper"

describe CoursesController do
  describe "routing" do

    it "routes to #index" do
      get("/courses").should route_to("courses#index")
    end

    it "routes to #new" do
      get("/courses/new").should route_to("courses#new")
    end

    it "routes to #show" do
      get("/courses/1").should route_to("courses#show", :id => "1")
    end

    it "routes to #edit" do
      get("/courses/1/edit").should route_to("courses#edit", :id => "1")
    end

    it "routes to #create" do
      post("/courses").should route_to("courses#create")
    end

    it "routes to #update" do
      put("/courses/1").should route_to("courses#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/courses/1").should route_to("courses#destroy", :id => "1")
    end

  end
end

require "spec_helper"

describe ExercisesController do
  describe "routing" do

    it "routes to #index" do
      get("/exercises").should route_to("exercises#index")
    end

    it "routes to #new" do
      get("/exercises/new").should route_to("exercises#new")
    end

    it "routes to #show" do
      get("/exercises/1").should route_to("exercises#show", :id => "1")
    end

    it "routes to #edit" do
      get("/exercises/1/edit").should route_to("exercises#edit", :id => "1")
    end

    it "routes to #create" do
      post("/exercises").should route_to("exercises#create")
    end

    it "routes to #update" do
      put("/exercises/1").should route_to("exercises#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/exercises/1").should route_to("exercises#destroy", :id => "1")
    end

  end
end

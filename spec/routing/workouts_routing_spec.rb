require "spec_helper"

describe WorkoutsController do
  describe "routing" do

    it "routes to #index" do
      get("/workouts").should route_to("workouts#index")
    end

    it "routes to #new" do
      get("/workouts/new").should route_to("workouts#new")
    end

    it "routes to #show" do
      get("/workouts/1").should route_to("workouts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/workouts/1/edit").should route_to("workouts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/workouts").should route_to("workouts#create")
    end

    it "routes to #update" do
      put("/workouts/1").should route_to("workouts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/workouts/1").should route_to("workouts#destroy", :id => "1")
    end

  end
end

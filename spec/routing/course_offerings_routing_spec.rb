require "spec_helper"

describe CourseOfferingsController do
  describe "routing" do

    it "routes to #index" do
      get("/course_offerings").should route_to("course_offerings#index")
    end

    it "routes to #new" do
      get("/course_offerings/new").should route_to("course_offerings#new")
    end

    it "routes to #show" do
      get("/course_offerings/1").should route_to("course_offerings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/course_offerings/1/edit").should route_to("course_offerings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/course_offerings").should route_to("course_offerings#create")
    end

    it "routes to #update" do
      put("/course_offerings/1").should route_to("course_offerings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/course_offerings/1").should route_to("course_offerings#destroy", :id => "1")
    end

  end
end

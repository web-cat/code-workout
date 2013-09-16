require "spec_helper"

describe CourseEnrollmentsController do
  describe "routing" do

    it "routes to #index" do
      get("/course_enrollments").should route_to("course_enrollments#index")
    end

    it "routes to #new" do
      get("/course_enrollments/new").should route_to("course_enrollments#new")
    end

    it "routes to #show" do
      get("/course_enrollments/1").should route_to("course_enrollments#show", :id => "1")
    end

    it "routes to #edit" do
      get("/course_enrollments/1/edit").should route_to("course_enrollments#edit", :id => "1")
    end

    it "routes to #create" do
      post("/course_enrollments").should route_to("course_enrollments#create")
    end

    it "routes to #update" do
      put("/course_enrollments/1").should route_to("course_enrollments#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/course_enrollments/1").should route_to("course_enrollments#destroy", :id => "1")
    end

  end
end

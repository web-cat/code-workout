require "spec_helper"

describe CourseRolesController do
  describe "routing" do

    it "routes to #index" do
      get("/course_roles").should route_to("course_roles#index")
    end

    it "routes to #new" do
      get("/course_roles/new").should route_to("course_roles#new")
    end

    it "routes to #show" do
      get("/course_roles/1").should route_to("course_roles#show", :id => "1")
    end

    it "routes to #edit" do
      get("/course_roles/1/edit").should route_to("course_roles#edit", :id => "1")
    end

    it "routes to #create" do
      post("/course_roles").should route_to("course_roles#create")
    end

    it "routes to #update" do
      put("/course_roles/1").should route_to("course_roles#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/course_roles/1").should route_to("course_roles#destroy", :id => "1")
    end

  end
end

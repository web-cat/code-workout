require "spec_helper"

describe PromptsController do
  describe "routing" do

    it "routes to #index" do
      get("/prompts").should route_to("prompts#index")
    end

    it "routes to #new" do
      get("/prompts/new").should route_to("prompts#new")
    end

    it "routes to #show" do
      get("/prompts/1").should route_to("prompts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/prompts/1/edit").should route_to("prompts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/prompts").should route_to("prompts#create")
    end

    it "routes to #update" do
      put("/prompts/1").should route_to("prompts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/prompts/1").should route_to("prompts#destroy", :id => "1")
    end

  end
end

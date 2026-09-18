require "spec_helper"

RSpec.describe WorkoutOfferingsController, type: :routing do
  describe "routing under /courses/:organization_id" do
    it "routes to #activity_log" do
      expect(get("/courses/uncc/itsc2214/fall-2026/14346/activity_log")).to route_to(
        controller: "workout_offerings",
        action: "activity_log",
        organization_id: "uncc",
        course_id: "itsc2214",
        term_id: "fall-2026",
        id: "14346"
      )
    end

    it "routes to #error" do
      expect(get("/courses/uncc/itsc2214/fall-2026/14346/error")).to route_to(
        controller: "workout_offerings",
        action: "error",
        organization_id: "uncc",
        course_id: "itsc2214",
        term_id: "fall-2026",
        id: "14346"
      )
    end

    it "routes to exercises#practice when an exercise ID is provided" do
      expect(get("/courses/uncc/itsc2214/fall-2026/14346/1024")).to route_to(
        controller: "exercises",
        action: "practice",
        organization_id: "uncc",
        course_id: "itsc2214",
        term_id: "fall-2026",
        workout_offering_id: "14346",
        id: "1024"
      )
    end
  end
end

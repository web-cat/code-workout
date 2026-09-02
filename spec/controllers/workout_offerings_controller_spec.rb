require 'spec_helper'

RSpec.describe WorkoutOfferingsController, type: :controller do
  describe "Fallback section resolution (resolve_section_offering)" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Practice Workout') }

    let(:section1) do
      FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term, label: 'Section 1')
    end
    let(:section2) do
      FactoryBot.build_stubbed(:course_offering, id: 102, course: course, term: term, label: 'Section 2')
    end

    let(:offering_section1) do
      FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: section1)
    end
    let(:offering_section2) do
      FactoryBot.build_stubbed(:workout_offering, id: 202, workout: workout, course_offering: section2)
    end

    let(:student) { FactoryBot.build_stubbed(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(student)
      allow(WorkoutOffering).to receive_message_chain(:includes, :find_by).and_return(offering_section1)
      allow(section1).to receive(:is_staff?).with(student).and_return(false)
      allow(section1).to receive(:is_enrolled?).with(student).and_return(false)
      allow(student).to receive(:course_offerings_for_term).with(term, course).and_return([section2])
      allow(WorkoutOffering).to receive(:where).with(
        course_offering_id: [102],
        workout_id: workout.id
      ).and_return([offering_section2])
    end

    it "redirects a student enrolled in Section 2 from Section 1's show URL to Section 2's offering" do
      get :show, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201'
      }

      expect(response).to redirect_to(
        organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: 202
        )
      )
    end

    it "redirects a student enrolled in Section 2 from Section 1's practice URL to Section 2's offering practice" do
      get :practice, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201',
        exercise_id: '5'
      }

      expect(response).to redirect_to(
        organization_workout_offering_practice_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: 202,
          exercise_id: '5'
        )
      )
    end
  end

  describe "GET #show" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Practice Workout', exercises: []) }
    let(:section1) do
      FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term, label: 'Section 1')
    end
    let(:workout_offering) do
      FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: section1)
    end
    let(:user) { FactoryBot.build_stubbed(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(WorkoutOffering).to receive_message_chain(:includes, :find_by).and_return(workout_offering)
      allow(section1).to receive(:is_staff?).with(user).and_return(true)
      allow(workout_offering).to receive(:score_for).and_return(nil)
    end

    it "renders the show view with preloaded workout, course, and attempt structures" do
      get :show, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201'
      }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@workout)).to eq(workout)
      expect(controller.instance_variable_get(:@course_offering)).to eq(section1)
      expect(controller.instance_variable_get(:@attempts_by_version_id)).to be_a(Hash)
    end

    context "when a workout score exists" do
      let(:workout_score) { double("WorkoutScore", scored_attempts: []) }

      before do
        allow(workout_offering).to receive(:score_for).with(user).and_return(workout_score)
      end

      it "preloads scored_attempts grouped by exercise_version_id" do
        get :show, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@scoring_attempts_by_version_id)).to be_a(Hash)
      end
    end
  end
end

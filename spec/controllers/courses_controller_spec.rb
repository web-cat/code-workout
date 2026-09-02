require 'spec_helper'

describe CoursesController do
  let(:valid_session) { {} }

  describe "GET show" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, id: 1, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, id: 2, slug: 'fall2026') }
    let(:user) { FactoryBot.build_stubbed(:user, id: 10) }

    it "assigns the requested course as @course" do
      allow(Organization).to receive(:find).and_return(organization)
      allow(Course).to receive(:find_with_id_or_slug).and_return(course)
      allow(controller).to receive(:authorize!).and_return(true)

      get :show, params: { organization_id: 'vt', id: 'cs1114' }, session: valid_session
      expect(controller.instance_variable_get(:@course)).to eq(course)
    end

    it "preloads offerings and batch loads workout scores when term is provided" do
      allow(Organization).to receive(:find).and_return(organization)
      allow(Course).to receive(:find_with_id_or_slug).and_return(course)
      allow(controller).to receive(:authorize!).and_return(true)
      allow(Term).to receive(:find).with('2').and_return(term)
      allow(controller).to receive(:current_user).and_return(user)

      course_offering = FactoryBot.build_stubbed(:course_offering, id: 100, course: course, term: term)
      relation = double('CourseOfferingsRelation', any?: true, first: course_offering, present?: true, respond_to?: true)
      allow(user).to receive(:course_offerings_for_term).with(term, course).and_return(relation)
      allow(relation).to receive(:includes).and_return([course_offering])
      allow(course_offering).to receive(:is_instructor?).with(user).and_return(false)
      allow(course_offering).to receive(:workout_offering_ids).and_return([201, 202])

      workout_score = double('WorkoutScore', workout_offering_id: 201, workout_id: 301, user_id: 10)
      scores_relation = double('ScoresRelation')
      allow(WorkoutScore).to receive(:where).with(workout_offering_id: [201, 202], user_id: 10).and_return(scores_relation)
      allow(scores_relation).to receive(:group_by).and_return({ 201 => [workout_score] })

      get :show, params: { organization_id: 'vt', id: 'cs1114', term_id: '2' }, session: valid_session

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@term)).to eq(term)
      expect(controller.instance_variable_get(:@workout_scores_by_offering_id)).to be_a(Hash)
    end
  end

  describe "GET tab_content" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, id: 1, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, id: 2, slug: 'fall2026') }
    let(:user) { FactoryBot.build_stubbed(:user, id: 10) }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 100, course: course, term: term) }

    before do
      allow(Organization).to receive(:find).and_return(organization)
      allow(Course).to receive(:find_with_id_or_slug).and_return(course)
      allow(controller).to receive(:authorize!).and_return(true)
      allow(Term).to receive(:find).and_return(term)
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive(:course_offerings_for_term).with(term, course).and_return([course_offering])
    end

    it "preloads workout offerings and scores for tab_workouts" do
      allow(course_offering).to receive(:workout_offering_ids).and_return([201])

      score = double('WorkoutScore', workout_offering_id: 201, workout_id: 301, user_id: 10)
      scores_relation = double('ScoresRelation')
      allow(WorkoutScore).to receive(:where).with(workout_offering_id: [201], user_id: 10).and_return(scores_relation)
      allow(scores_relation).to receive(:group_by).and_return({ 201 => [score] })

      get :tab_content, params: { organization_id: 'vt', course_id: 'cs1114', term_id: '2', tab: 'tab_workouts' }, format: :js, session: valid_session
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@workout_scores_by_offering_id)).to be_a(Hash)
    end

    it "batch-loads workout scores for tab_grades in instructor mode" do
      allow(user).to receive_message_chain(:global_role, :is_admin?).and_return(true)
      allow(course_offering).to receive(:workout_offering_ids).and_return([201])

      enrollment = double('CourseEnrollment', course_role_id: CourseRole::STUDENT_ID, user_id: 55)
      allow(course_offering).to receive(:course_enrollments).and_return([enrollment])

      score = double('WorkoutScore', workout_offering_id: 201, user_id: 55)
      scores_relation = double('ScoresRelation')
      allow(WorkoutScore).to receive(:where).with(workout_offering_id: [201], user_id: [55]).and_return(scores_relation)
      allow(scores_relation).to receive(:order).with('updated_at DESC').and_return(scores_relation)
      allow(scores_relation).to receive(:group_by).and_return({ [201, 55] => [score] })

      get :tab_content, params: { organization_id: 'vt', course_id: 'cs1114', term_id: '2', tab: 'tab_grades' }, format: :js, session: valid_session
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@workout_scores_by_offering_and_user)).to be_a(Hash)
    end

    it "eager loads exercises for tab_exercises" do
      exercises_relation = double('ExercisesRelation')
      allow(course).to receive(:exercises).and_return(exercises_relation)
      allow(exercises_relation).to receive(:includes).with(:exercise_family, :current_version).and_return([])

      get :tab_content, params: { organization_id: 'vt', course_id: 'cs1114', term_id: '2', tab: 'tab_exercises' }, format: :js, session: valid_session
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@exercises)).to eq([])
    end
  end
end

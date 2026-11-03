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

    it "sets @as_student to true when course staff passes student=true" do
      allow(Organization).to receive(:find).and_return(organization)
      allow(Course).to receive(:find_with_id_or_slug).and_return(course)
      allow(controller).to receive(:authorize!).and_return(true)
      allow(Term).to receive(:find).with('2').and_return(term)
      allow(controller).to receive(:current_user).and_return(user)

      course_offering = FactoryBot.build_stubbed(:course_offering, id: 100, course: course, term: term)
      relation = double('CourseOfferingsRelation', any?: true, first: course_offering, present?: true, respond_to?: true)
      allow(user).to receive(:course_offerings_for_term).with(term, course).and_return(relation)
      allow(relation).to receive(:includes).and_return([course_offering])
      allow(course_offering).to receive(:is_staff?).with(user).and_return(true)
      allow(course_offering).to receive(:is_instructor?).with(user).and_return(true)
      allow(course_offering).to receive(:workout_offering_ids).and_return([])

      get :show, params: { organization_id: 'vt', id: 'cs1114', term_id: '2', student: 'true' }, session: valid_session

      expect(controller.instance_variable_get(:@can_view_as_student)).to be true
      expect(controller.instance_variable_get(:@as_student)).to be true
      expect(controller.instance_variable_get(:@is_instructor)).to be false
      expect(controller.instance_variable_get(:@is_student)).to be true
    end

    it "does not allow non-staff student to enable @as_student" do
      allow(Organization).to receive(:find).and_return(organization)
      allow(Course).to receive(:find_with_id_or_slug).and_return(course)
      allow(controller).to receive(:authorize!).and_return(true)
      allow(Term).to receive(:find).with('2').and_return(term)
      allow(controller).to receive(:current_user).and_return(user)

      course_offering = FactoryBot.build_stubbed(:course_offering, id: 100, course: course, term: term)
      relation = double('CourseOfferingsRelation', any?: true, first: course_offering, present?: true, respond_to?: true)
      allow(user).to receive(:course_offerings_for_term).with(term, course).and_return(relation)
      allow(relation).to receive(:includes).and_return([course_offering])
      allow(course_offering).to receive(:is_staff?).with(user).and_return(false)
      allow(course_offering).to receive(:is_instructor?).with(user).and_return(false)
      allow(course_offering).to receive(:workout_offering_ids).and_return([])

      get :show, params: { organization_id: 'vt', id: 'cs1114', term_id: '2', student: 'true' }, session: valid_session

      expect(controller.instance_variable_get(:@can_view_as_student)).to be false
      expect(controller.instance_variable_get(:@as_student)).to be false
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

  describe "Authorization and Security" do
    let(:organization) { FactoryBot.build_stubbed(:organization, id: 1, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, id: 1, slug: 'cs1114', organization: organization) }

    before do
      allow(Organization).to receive(:find).and_return(organization)
      allow(Course).to receive(:find_with_id_or_slug).and_return(course)
      allow(Course).to receive(:find).and_return(course)
    end

    describe "GET #new" do
      it "authorizes :create on Course" do
        expect(controller).to receive(:authorize!).with(:create, Course)
        get :new, params: { organization_id: 'vt' }
      end

      it "denies unauthorized users from accessing new course form" do
        allow(controller).to receive(:authorize!).with(:create, Course).and_raise(CanCan::AccessDenied.new("Not authorized!"))
        get :new, params: { organization_id: 'vt' }
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to be_present
      end
    end

    describe "POST #create" do
      it "authorizes :create on Course" do
        expect(controller).to receive(:authorize!).with(:create, Course)
        allow_any_instance_of(Course).to receive(:save) do |instance|
          instance.id = 100
          true
        end
        allow(UserGroup).to receive(:create).and_return(double('UserGroup', add_user_to_group: true))

        post :create, params: {
          organization_id: 'vt',
          course: { name: 'Intro', number: 'CS 101', slug: 'cs101' }
        }
      end

      it "denies unauthorized users from creating courses" do
        allow(controller).to receive(:authorize!).with(:create, Course).and_raise(CanCan::AccessDenied.new("Not authorized!"))
        post :create, params: {
          organization_id: 'vt',
          course: { name: 'Intro', number: 'CS 101', slug: 'cs101' }
        }
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to be_present
      end
    end

    describe "GET #edit" do
      it "authorizes :update on @course" do
        expect(controller).to receive(:authorize!).with(:update, course)
        get :edit, params: { organization_id: 'vt', id: 'cs1114' }
      end

      it "denies unauthorized users from editing courses" do
        allow(controller).to receive(:authorize!).with(:update, course).and_raise(CanCan::AccessDenied.new("Not authorized!"))
        get :edit, params: { organization_id: 'vt', id: 'cs1114' }
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to be_present
      end
    end

    describe "POST #generate_gradebook" do
      it "authorizes :generate_gradebook on @course" do
        expect(controller).to receive(:authorize!).with(:generate_gradebook, course)
        post :generate_gradebook, params: { organization_id: 'vt', id: 'cs1114', term_id: 'fall2026' }, format: :csv
      end

      it "denies unauthorized users from generating gradebooks" do
        allow(controller).to receive(:authorize!).with(:generate_gradebook, course).and_raise(CanCan::AccessDenied.new("Not authorized!"))
        post :generate_gradebook, params: { organization_id: 'vt', id: 'cs1114', term_id: 'fall2026' }, format: :csv
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to be_present
      end
    end

    describe "GET #search" do
      it "authorizes :search on Course and escapes SQL wildcards" do
        expect(controller).to receive(:authorize!).with(:search, Course)
        courses_relation = double('CoursesRelation')
        allow(organization).to receive(:courses).and_return(courses_relation)

        expect(courses_relation).to receive(:where).with(
          'lower(name) like ? or lower(number) like ? or slug like ?',
          '%test\\%query%',
          '%test\\%query%',
          '%test\\%query%'
        ).and_return([])

        get :search, params: { organization_id: 'vt', term: 'test%query' }, format: :json
        expect(response.status).to eq(200)
      end
    end
  end
end

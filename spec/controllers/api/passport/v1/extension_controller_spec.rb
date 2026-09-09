require 'spec_helper'

RSpec.describe Api::Passport::V1::ExtensionController, type: :controller do
  let(:lms_instance) { FactoryBot.build_stubbed(:lms_instance, id: 1, url: 'https://canvas.example.edu') }
  let(:user) { FactoryBot.build_stubbed(:user, id: 42) }
  let(:identity) { FactoryBot.build_stubbed(:lti_identity, lms_instance: lms_instance, user: user, lti_user_id: 'lti_user_123') }

  let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Practice Workout') }
  let(:course_offering_1) { FactoryBot.build_stubbed(:course_offering, id: 101, label: 'Section 1') }
  let(:course_offering_2) { FactoryBot.build_stubbed(:course_offering, id: 102, label: 'Section 2') }

  let(:workout_offering_1) do
    FactoryBot.build_stubbed(
      :workout_offering,
      id: 201,
      course_offering: course_offering_1,
      workout: workout,
      lms_instance: lms_instance,
      lti_assignment_id: 'shared_uuid'
    )
  end
  let(:workout_offering_2) do
    FactoryBot.build_stubbed(
      :workout_offering,
      id: 202,
      course_offering: course_offering_2,
      workout: workout,
      lms_instance: lms_instance,
      lti_assignment_id: 'shared_uuid'
    )
  end

  before do
    allow(controller).to receive(:verify_signature!).and_return(true)
    allow(LmsInstance).to receive(:find_by).with(url: 'https://canvas.example.edu').and_return(lms_instance)
    allow(LtiIdentity).to receive(:find_by).with(lms_instance: lms_instance, lti_user_id: 'lti_user_123').and_return(identity)
  end

  describe 'POST #create' do
    it 'scopes workout offering to the section where the user is enrolled when multiple sections share lti_assignment_id' do
      scoped_relation = instance_double(ActiveRecord::Relation)
      allow(WorkoutOffering).to receive(:joins).with(course_offering: :course_enrollments).and_return(scoped_relation)
      allow(scoped_relation).to receive(:where).with(lms_instance: lms_instance).and_return(scoped_relation)
      allow(scoped_relation).to receive(:where).with(course_enrollments: { user_id: user.id }).and_return(scoped_relation)
      allow(scoped_relation).to receive(:where).with(
        'workout_offerings.lti_assignment_id = :id OR workout_offerings.resource_link_id = :id OR workout_offerings.lms_assignment_id = :id',
        id: 'shared_uuid'
      ).and_return([workout_offering_2])

      allow(StudentExtension).to receive(:find_by).with(user: user, workout_offering: workout_offering_2).and_return(nil)
      expect(StudentExtension).to receive(:create_or_update!).with(
        user,
        workout_offering_2,
        hash_including('soft_deadline', 'hard_deadline')
      )

      post :create, params: {
        context: { issuer: 'https://canvas.example.edu' },
        user: { lti_user_id: 'lti_user_123' },
        resource: { lti_resource_link_id: 'shared_uuid' },
        extension: { new_due_date: 2.days.from_now.iso8601 }
      }, as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'falls back to any matching offering when the user is not yet enrolled in a section' do
      scoped_relation = instance_double(ActiveRecord::Relation)
      allow(WorkoutOffering).to receive(:joins).with(course_offering: :course_enrollments).and_return(scoped_relation)
      allow(scoped_relation).to receive(:where).with(lms_instance: lms_instance).and_return(scoped_relation)
      allow(scoped_relation).to receive(:where).with(course_enrollments: { user_id: user.id }).and_return(scoped_relation)
      allow(scoped_relation).to receive(:where).with(
        'workout_offerings.lti_assignment_id = :id OR workout_offerings.resource_link_id = :id OR workout_offerings.lms_assignment_id = :id',
        id: 'shared_uuid'
      ).and_return([])

      allow(WorkoutOffering).to receive(:find_by).with(lms_instance: lms_instance, lti_assignment_id: 'shared_uuid').and_return(workout_offering_1)
      allow(StudentExtension).to receive(:find_by).with(user: user, workout_offering: workout_offering_1).and_return(nil)
      expect(StudentExtension).to receive(:create_or_update!).with(
        user,
        workout_offering_1,
        hash_including('soft_deadline', 'hard_deadline')
      )

      post :create, params: {
        context: { issuer: 'https://canvas.example.edu' },
        user: { lti_user_id: 'lti_user_123' },
        resource: { lti_resource_link_id: 'shared_uuid' },
        extension: { new_due_date: 2.days.from_now.iso8601 }
      }, as: :json

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE #destroy' do
    it 'removes extension associated with the enrolled offering' do
      scoped_relation = instance_double(ActiveRecord::Relation)
      allow(WorkoutOffering).to receive(:joins).with(course_offering: :course_enrollments).and_return(scoped_relation)
      allow(scoped_relation).to receive(:where).with(lms_instance: lms_instance).and_return(scoped_relation)
      allow(scoped_relation).to receive(:where).with(course_enrollments: { user_id: user.id }).and_return(scoped_relation)
      allow(scoped_relation).to receive(:where).with(
        'workout_offerings.lti_assignment_id = :id OR workout_offerings.resource_link_id = :id OR workout_offerings.lms_assignment_id = :id',
        id: 'shared_uuid'
      ).and_return([workout_offering_2])

      ext = instance_double(StudentExtension, id: 999)
      allow(StudentExtension).to receive(:find_by).with(user: user, workout_offering: workout_offering_2).and_return(ext)
      expect(ext).to receive(:destroy).and_return(true)

      delete :destroy, params: {
        context: { issuer: 'https://canvas.example.edu' },
        user: { lti_user_id: 'lti_user_123' },
        resource: { lti_resource_link_id: 'shared_uuid' }
      }, as: :json

      expect(response).to have_http_status(:ok)
    end
  end
end

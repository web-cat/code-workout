# frozen_string_literal: true

require 'spec_helper'

RSpec.describe User, type: :model do
  describe '.lti_new_or_existing_user' do
    let(:email) { 'new_student@vt.edu' }
    let(:opts) do
      {
        lis_person_contact_email_primary: email,
        first_name: 'Test',
        last_name: 'Student'
      }
    end

    it 'returns existing user if user is found by email' do
      existing_user = FactoryBot.build_stubbed(:user, email: email)
      allow(User).to receive(:find_by).with(email: email).and_return(existing_user)

      result = User.lti_new_or_existing_user(opts)
      expect(result).to eq(existing_user)
    end

    it 'rescues RecordNotUnique and retrieves existing user on race condition' do
      existing_user = FactoryBot.build_stubbed(:user, email: email)

      # First call to find_by returns nil (user not found yet)
      # Second call after RecordNotUnique returns the existing user created concurrently
      allow(User).to receive(:find_by).with(email: email).and_return(nil, existing_user)

      new_user_instance = User.new(email: email, first_name: 'Test', last_name: 'Student')
      allow(User).to receive(:new).and_return(new_user_instance)
      allow(new_user_instance).to receive(:save!).and_raise(ActiveRecord::RecordNotUnique.new("Duplicate entry"))

      result = User.lti_new_or_existing_user(opts)
      expect(result).to eq(existing_user)
    end

    context 'when email is blank' do
      let(:lms_instance) { FactoryBot.build_stubbed(:lms_instance, id: 99) }
      let(:lti_user_id) { 'canvas-test-user-123' }

      it 'raises ArgumentError if launch is not for a test student' do
        regular_student_opts = {
          lis_person_contact_email_primary: '',
          first_name: 'Jane',
          last_name: 'Doe',
          full_name: 'Jane Doe',
          lms_instance: lms_instance,
          lti_user_id: lti_user_id
        }

        expect {
          User.lti_new_or_existing_user(regular_student_opts)
        }.to raise_error(ArgumentError, /Expected opts\[:lis_person_contact_email_primary\] to be a valid email address/)
      end

      it 'creates a synthetic user when launch is for a test student' do
        test_student_opts = {
          lis_person_contact_email_primary: '',
          first_name: 'Test',
          last_name: 'Student',
          full_name: 'Test Student',
          lms_instance: lms_instance,
          lti_user_id: lti_user_id,
          custom_canvas_api_domain: 'canvas.vt.edu'
        }

        expected_email = "teststudent-99-canvas-test-user-123@canvas.vt.edu"
        created_user = FactoryBot.build_stubbed(:user, email: expected_email, first_name: 'Test', last_name: 'Student')

        allow(User).to receive(:find_by).with(email: expected_email).and_return(nil)
        user_double = instance_double(User)
        expect(User).to receive(:new).with(hash_including(
          email: expected_email,
          first_name: 'Test',
          last_name: 'Student'
        )).and_return(user_double)
        expect(user_double).to receive(:skip_password_validation=).with(true)
        expect(user_double).to receive(:save!).and_return(true)

        result = User.lti_new_or_existing_user(test_student_opts)
        expect(result).to eq(user_double)
      end

      it 'returns existing user if already linked via lti_identity' do
        existing_test_user = FactoryBot.build_stubbed(:user, email: 'teststudent-99-canvas-test-user-123@canvas.vt.edu')
        lti_identity = instance_double('LtiIdentity', user: existing_test_user)

        test_student_opts = {
          lti_identity: lti_identity,
          lis_person_contact_email_primary: '',
          first_name: 'Test',
          last_name: 'Student'
        }

        result = User.lti_new_or_existing_user(test_student_opts)
        expect(result).to eq(existing_test_user)
      end
    end
  end

  describe '.test_student_launch?' do
    it 'returns true for full_name Test Student' do
      expect(User.test_student_launch?(full_name: 'Test Student')).to be true
      expect(User.test_student_launch?(full_name: 'test student')).to be true
    end

    it 'returns true for first_name Test and last_name Student' do
      expect(User.test_student_launch?(first_name: 'Test', last_name: 'Student')).to be true
      expect(User.test_student_launch?(first_name: 'TEST', last_name: 'STUDENT')).to be true
    end

    it 'returns false for regular users' do
      expect(User.test_student_launch?(first_name: 'John', last_name: 'Doe')).to be false
      expect(User.test_student_launch?(full_name: 'John Doe')).to be false
      expect(User.test_student_launch?({})).to be false
      expect(User.test_student_launch?(nil)).to be false
    end
  end

  describe '#managed_course_offerings' do
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:course) { FactoryBot.build_stubbed(:course, id: 10) }
    let(:term) { FactoryBot.build_stubbed(:term, id: 20) }

    it 'includes :course_role in joins when course and term are provided' do
      relation = double('EnrollmentsRelation')
      allow(user).to receive(:course_enrollments).and_return(relation)
      joined_relation = double('JoinedRelation')
      allow(relation).to receive(:joins).with(:course_role, :course_offering).and_return(joined_relation)
      where_relation = double('WhereRelation')
      allow(joined_relation).to receive(:where).with(
        'course_roles.can_manage_course = true and
          course_offerings.course_id = ? and course_offerings.term_id = ?',
        10, 20
      ).and_return(where_relation)
      allow(where_relation).to receive(:map).and_return([])

      result = user.managed_course_offerings(course: course, term: term)
      expect(result).to eq([])
    end
  end

  describe '#managed_workout_offerings_in_term' do
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:course) { FactoryBot.build_stubbed(:course, id: 10) }
    let(:term) { FactoryBot.build_stubbed(:term, id: 20) }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 30) }

    it 'includes :course_role in joins when term is present' do
      relation = double('EnrollmentsRelation')
      allow(user).to receive(:course_enrollments).and_return(relation)
      joined_relation = double('JoinedRelation')
      allow(relation).to receive(:joins).with(:course_role, course_offering: :workout_offerings).and_return(joined_relation)
      where_relation = double('WhereRelation')
      allow(joined_relation).to receive(:where).with(
        course_roles: { can_manage_course: true },
        course_offerings: { course: course, term: term }
      ).and_return(where_relation)
      allow(where_relation).to receive(:map).and_return([])

      result = user.managed_workout_offerings_in_term(workout, course, term)
      expect(result).to eq([])
    end
  end
end

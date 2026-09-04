# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LtiController, type: :controller do
  describe 'POST #launch' do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:lms_instance) do
      FactoryBot.build_stubbed(:lms_instance, id: 1, consumer_key: 'canvas_key', organization: organization)
    end
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cbtf', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall-2026') }

    let(:test_student_params) do
      {
        oauth_consumer_key: 'canvas_key',
        user_id: 'test_user_123',
        lis_person_name_full: 'Test Student',
        lis_person_name_given: 'Test',
        lis_person_name_family: 'Student',
        lis_person_contact_email_primary: '',
        custom_canvas_api_domain: 'canvas.vt.edu',
        resource_link_title: 'Example CBTF Question',
        custom_term: 'fall-2026',
        context_title: 'CBTF test area',
        context_label: 'cbtf'
      }
    end

    before do
      allow(controller).to receive(:lti_authorize!).and_return(true)
      tool_provider = instance_double(IMS::LTI::ToolProvider, context_instructor?: false)
      controller.instance_variable_set(:@tp, tool_provider)
      allow(LmsInstance).to receive(:find_by).with(consumer_key: 'canvas_key').and_return(lms_instance)
      allow(LtiIdentity).to receive(:find_by).and_return(nil)
      allow(Course).to receive(:find_by).and_return(course)
      allow(Term).to receive(:find_by).and_return(term)
    end

    it 'creates a synthetic user and proceeds with launch for Canvas Test Student' do
      test_user = FactoryBot.build_stubbed(
        :user,
        id: 50,
        email: 'teststudent-1-test_user_123@canvas.vt.edu',
        first_name: 'Test',
        last_name: 'Student'
      )
      allow(test_user).to receive(:lti_identities).and_return(LtiIdentity.none)
      allow(test_user).to receive(:save!).and_return(true)
      allow(LtiIdentity).to receive(:new).and_return(instance_double(LtiIdentity, save!: true))
      expect(User).to receive(:lti_new_or_existing_user).with(hash_including(
        lms_instance: lms_instance,
        lti_user_id: 'test_user_123',
        lis_person_contact_email_primary: '',
        full_name: 'Test Student'
      )).and_return(test_user)
      allow(controller).to receive(:sign_in).with(test_user).and_return(true)

      post :launch, params: test_student_params

      expect(response).to be_redirect
      expect(response.location).to start_with("http://test.host/courses/vt/cbtf/fall-2026/find_offering/Example%20CBTF%20Question")
      expect(response.location).to include("user_id=50")
    end

    it 'raises ArgumentError if non-test student is missing email' do
      non_test_params = test_student_params.merge(
        lis_person_name_full: 'John Doe',
        lis_person_name_given: 'John',
        lis_person_name_family: 'Doe'
      )

      expect {
        post :launch, params: non_test_params
      }.to raise_error(ArgumentError, /Expected opts\[:lis_person_contact_email_primary\] to be a valid email address/)
    end
  end
end

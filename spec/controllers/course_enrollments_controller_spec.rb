require 'spec_helper'

describe CourseEnrollmentsController, type: :controller do
  render_views
  let(:user) { FactoryBot.build_stubbed(:admin, id: 1) }
  let(:mock_org) { double('Organization', id: 1, slug: 'vt', to_param: 'vt') }
  let(:mock_course) { double('Course', id: 10, slug: 'cs1114', to_param: 'cs1114', organization: mock_org) }
  let(:mock_term) { double('Term', id: 20, slug: 'fall2026', to_param: 'fall2026', display_name: 'Fall 2026') }
  let(:mock_course_offering) do
    double('CourseOffering', id: 300, display_name: 'CS 1114 (Fall 2026, 98765)', display_name_with_term: 'CS 1114 (Fall 2026, 98765)', term: mock_term)
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(Term).to receive(:find).and_return(mock_term)
    allow(Organization).to receive(:find).and_return(mock_org)
    allow(Course).to receive(:find_with_id_or_slug).and_return(mock_course)
    allow(user).to receive(:course_offerings_for_term).and_return([mock_course_offering])
  end

  describe 'GET #new (js format)' do
    it 'renders the new.js.erb template without leaving raw ERB tags' do
      get :new, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026'
      }, format: :js

      expect(response.status).to eq(200)
      expect(response.body).to include("const courseId = 'cs1114'")
      expect(response.body).to include("const organizationId = 'vt'")
      expect(response.body).to include("const termId = 'fall2026'")
      expect(response.body).not_to include('<%=')
      expect(response.body).not_to include('%>')
    end
  end

  describe 'GET #choose_roster (js format)' do
    it 'renders the choose_roster.js.coffee template successfully' do
      get :choose_roster, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026'
      }, format: :js

      expect(response.status).to eq(200)
      expect(response.body).to include('roster-upload-modal')
      expect(response.body).not_to include('<%=')
      expect(response.body).not_to include('%>')
    end
  end
end

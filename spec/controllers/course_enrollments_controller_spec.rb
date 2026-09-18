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

  describe 'POST #roster_upload' do
    let(:course_offering) do
      double(
        'CourseOffering',
        id: 300,
        course: mock_course,
        term: mock_term,
        is_enrolled?: false
      )
    end

    before do
      allow(CourseOffering).to receive(:find).with('300').and_return(course_offering)
    end

    it 'flashes an error and redirects if no file is provided' do
      post :roster_upload, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        course_offering_id: '300'
      }

      expect(flash[:error]).to eq('Please choose a CSV file to upload.')
      expect(response).to redirect_to(organization_course_path(id: 'cs1114', organization_id: 'vt', term_id: 'fall2026'))
    end

    it 'flashes an error when CSV headers are missing or incorrect' do
      tempfile = Tempfile.new(['roster', '.csv'])
      tempfile.write("email,first_name,last_name,Role\ntest@example.com,John,Doe,Student\n")
      tempfile.rewind
      file = Rack::Test::UploadedFile.new(tempfile.path, 'text/csv')

      post :roster_upload, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        course_offering_id: '300',
        rosterfile: file,
        has_headers: 'true'
      }

      expect(flash[:error]).to include('Missing required header(s): course_role')
      expect(flash[:error]).to include('Expected headers: email, first_name, last_name, course_role')
      expect(response).to redirect_to(organization_course_path(id: 'cs1114', organization_id: 'vt', term_id: 'fall2026'))
    end

    it 'successfully enrolls users when headers are valid' do
      tempfile = Tempfile.new(['roster', '.csv'])
      tempfile.write("email,first_name,last_name,course_role\nnewuser@example.com,Jane,Doe,Student\n")
      tempfile.rewind
      file = Rack::Test::UploadedFile.new(tempfile.path, 'text/csv')

      mock_role = double('CourseRole', id: 1)
      allow(CourseRole).to receive(:student).and_return(mock_role)
      allow(CourseRole).to receive(:instructor).and_return(double('CourseRole', id: 2))
      allow(CourseRole).to receive(:grader).and_return(double('CourseRole', id: 3))

      new_user = double('User', id: 99, email: 'newuser@example.com')
      allow(User).to receive(:find_by).with(email: 'newuser@example.com').and_return(nil)
      allow(User).to receive(:new).and_return(new_user)
      allow(new_user).to receive(:first_name=)
      allow(new_user).to receive(:last_name=)
      allow(new_user).to receive(:skip_password_validation=)
      allow(new_user).to receive(:save).and_return(true)

      allow(CourseEnrollment).to receive(:create).with(
        course_offering: course_offering,
        user: new_user,
        course_role: mock_role
      ).and_return(true)

      post :roster_upload, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        course_offering_id: '300',
        rosterfile: file,
        has_headers: 'true'
      }

      expect(flash[:success]).to include('1 new user accounts created')
      expect(flash[:success]).to include('1 users enrolled')
      expect(response).to redirect_to(organization_course_path(id: 'cs1114', organization_id: 'vt', term_id: 'fall2026'))
    end
  end
end

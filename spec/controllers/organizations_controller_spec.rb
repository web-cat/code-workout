require 'spec_helper'

describe OrganizationsController, type: :controller do
  render_views

  let(:user) { FactoryBot.build_stubbed(:user) }
  let(:mock_org) { double('Organization', id: 1, name: 'Virginia Tech', slug: 'vt', to_param: 'vt', is_hidden: false) }
  let(:mock_term) { double('Term', id: 20, slug: 'fall-2026', to_param: 'fall-2026', display_name: 'Fall 2026') }
  let(:mock_course) do
    double(
      'Course',
      id: 10,
      name: 'Intro to Software Design',
      number: 'CS 1114',
      number_and_name: 'CS 1114 Intro to Software Design',
      slug: 'cs1114',
      to_param: 'cs1114',
      is_hidden: false,
      organization: mock_org,
      user_group: nil
    )
  end
  let(:mock_instructor) { double('User', id: 50, display_name: 'Dr. Jane Smith', to_param: '50') }
  let(:mock_course_offering) do
    double(
      'CourseOffering',
      id: 300,
      label: 'Section 1',
      display_name: 'CS 1114 (Section 1)',
      term: mock_term,
      course: mock_course,
      instructors: [mock_instructor],
      effective_cutoff_date: Date.today + 30.days,
      self_enrollment_allowed?: true,
      can_enroll?: true,
      is_enrolled?: false,
      is_instructor?: false,
      is_grader?: false,
      is_student?: false
    )
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(Term).to receive(:find).with('20').and_return(mock_term)
    allow(Term).to receive(:all).and_return([mock_term])
    allow(CourseOffering).to receive_message_chain(:where, :includes).and_return([mock_course_offering])
  end

  describe 'GET #index' do
    it 'renders the organizations index page with courses and offerings' do
      get :index, params: { term_id: '20' }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@term)).to eq(mock_term)
      expect(controller.instance_variable_get(:@organizations)).to eq([mock_org])
      expect(controller.instance_variable_get(:@courses_by_organization)[mock_org]).to eq([mock_course])
      expect(controller.instance_variable_get(:@offerings_by_course)[mock_course]).to eq([mock_course_offering])
      expect(response.body).to include('Virginia Tech')
      expect(response.body).to include('CS 1114')
      expect(response.body).to include('Dr. Jane Smith')
    end

    it 'renders empty message when no offerings are found' do
      allow(CourseOffering).to receive_message_chain(:where, :includes).and_return([])

      get :index, params: { term_id: '20' }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@organizations)).to eq([])
      expect(response.body).to include('No organizations have courses offered in')
    end
  end
end

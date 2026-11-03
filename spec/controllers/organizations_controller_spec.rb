require 'spec_helper'

describe OrganizationsController, type: :controller do
  render_views

  let(:user) { FactoryBot.build_stubbed(:user) }
  let(:mock_org) { double('Organization', id: 1, name: 'Virginia Tech', abbreviation: 'VT', slug: 'vt', to_param: 'vt', is_hidden: false) }
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

  describe 'GET #show' do
    before do
      allow(Organization).to receive_message_chain(:accessible_by, :find).and_return(mock_org)
      allow(CourseOffering).to receive_message_chain(:where, :joins, :where, :includes).and_return([mock_course_offering])
    end

    it 'renders the organization show page with courses for the given term' do
      get :show, params: { id: 'vt', term_id: '20' }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@organization)).to eq(mock_org)
      expect(controller.instance_variable_get(:@term)).to eq(mock_term)
      expect(controller.instance_variable_get(:@courses)).to eq([mock_course])
      expect(response.body).to include('Courses from')
      expect(response.body).to include('Virginia Tech')
      expect(response.body).to include('CS 1114')
    end

    it 'renders empty message without crashing when organization has no courses in term' do
      allow(CourseOffering).to receive_message_chain(:where, :joins, :where, :includes).and_return([])

      get :show, params: { id: 'vt', term_id: '20' }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@organization)).to eq(mock_org)
      expect(controller.instance_variable_get(:@courses)).to eq([])
      expect(response.body).to include('This organization does not have any courses in')
      expect(response.body).to include('Fall 2026')
    end

    it 'defaults to Term.current_term when term_id is omitted' do
      allow(Term).to receive(:current_term).and_return(mock_term)

      get :show, params: { id: 'vt' }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@term)).to eq(mock_term)
    end
  end

  describe 'POST #create' do
    it 'authorizes :create on Organization' do
      expect(controller).to receive(:authorize!).with(:create, Organization)
      allow_any_instance_of(Organization).to receive(:save).and_return(true)

      post :create, params: { name: 'Virginia Tech', abbreviation: 'VT' }
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['id']).to eq('vt')
    end

    it 'denies unauthorized users from creating organizations' do
      allow(controller).to receive(:authorize!).with(:create, Organization).and_raise(CanCan::AccessDenied.new("Not authorized!"))

      post :create, params: { name: 'Virginia Tech', abbreviation: 'VT' }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to be_present
    end
  end

  describe 'GET #search' do
    it 'escapes SQL wildcards in search query' do
      relation = double('ActiveRecord::Relation')
      expect(Organization).to receive(:where).with(
        'lower(name) like ? or lower(abbreviation) like ? or slug like ?',
        '%test\\%org%',
        '%test\\%org%',
        '%test\\%org%'
      ).and_return(relation)
      allow(relation).to receive(:to_json).and_return('[]')

      get :search, params: { term: 'test%org' }
      expect(response.status).to eq(200)
    end
  end
end

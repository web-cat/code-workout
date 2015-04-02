require 'spec_helper'

describe 'Courses' do
  describe 'GET /courses/vt/cs1114' do
    it 'works! (now write some real specs)' do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get organization_course_path(Organization.find('vt'), Course.find(1))
      expect(response.status).to be(200)
    end
  end
end

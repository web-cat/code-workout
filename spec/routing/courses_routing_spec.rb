require 'spec_helper'

describe CoursesController do
  describe 'routing' do

    it 'routes to #show' do
      expect(get: '/courses/vt/cs1114').to route_to(
        'courses#show',
        id: 'cs1114',
        organization_id: 'vt')
    end

  end
end

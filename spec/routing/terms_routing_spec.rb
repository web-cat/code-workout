require 'spec_helper'

describe TermsController do
  describe 'routing' do

    # terms are included in routes targeting the courses controller
    it 'routes to #show' do
      expect(get: '/courses/vt/cs1114/spring-2015').to route_to(
        'courses#show',
        id: 'cs1114',
        organization_id: 'vt',
        term_id: 'spring-2015')
    end

  end
end

require 'spec_helper'

describe OrganizationsController do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/courses').to route_to('organizations#index')
    end

    it 'routes to #new' do
      # Treats /new as a slug for an organization
      expect(get: '/courses/new').to route_to('organizations#show', id: 'new')
    end

    it 'routes to #show' do
      expect(get: '/courses/1').to route_to('organizations#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/courses/1/edit').to route_to(
        'courses#show', id: 'edit', organization_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/courses').not_to be_routable
    end

    it 'routes to #update' do
      expect(put: '/courses/1').not_to be_routable
    end

    it 'routes to #destroy' do
      expect(delete: '/courses/1').not_to be_routable
    end

  end
end

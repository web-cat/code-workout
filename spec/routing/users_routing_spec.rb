require 'spec_helper'

describe UsersController do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/users').to route_to('users#index')
    end

    it 'routes to #new' do
      expect(get: '/users/new').to route_to('users#new')
    end

    it 'routes to #show' do
      expect(get: '/users/admin@codeworkout.org').to route_to(
        'users#show',
        id: 'admin@codeworkout.org')
    end

    it 'routes to #calc_performance' do
      expect(get: '/users/admin@codeworkout.org/performance').to route_to(
        'users#calc_performance',
        user_id: 'admin@codeworkout.org')
    end

    it 'routes to #edit' do
      expect(get: '/users/admin@codeworkout.org/edit').to route_to(
        'users#edit',
        id: 'admin@codeworkout.org')
    end

    it 'routes to #create' do
      expect(post: '/users').to route_to('users#create')
    end

    it 'routes to #update' do
      expect(put: '/users/admin@codeworkout.org').to route_to(
        'users#update',
        id: 'admin@codeworkout.org')
    end

    it 'routes to #destroy' do
      expect(delete: '/users/admin@codeworkout.org').to route_to(
        'users#destroy',
        id: 'admin@codeworkout.org')
    end

  end
end

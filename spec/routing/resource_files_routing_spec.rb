require 'spec_helper'

describe ResourceFilesController do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/users/admin@codeworkout.org/media').to route_to(
        'resource_files#index',
        user_id: 'admin@codeworkout.org')
    end

    it 'routes to #new' do
      expect(get: '/users/admin@codeworkout.org/media/new').to route_to(
        'resource_files#new',
        user_id: 'admin@codeworkout.org')
    end

    it 'routes to #show' do
      expect(get: '/users/admin@codeworkout.org/media/file.png').to route_to(
        'resource_files#show',
        user_id: 'admin@codeworkout.org',
        id: 'file.png')
    end

    it 'routes to #edit' do
      expect(get: '/users/admin@codeworkout.org/media/file.png/edit').
        to route_to(
        'resource_files#edit',
        user_id: 'admin@codeworkout.org',
        id: 'file.png')
    end

    it 'routes to #create' do
      expect(post: '/users/admin@codeworkout.org/media').to route_to(
        'resource_files#create',
        user_id: 'admin@codeworkout.org')
    end

    it 'routes to #update' do
      expect(put: '/users/admin@codeworkout.org/media/file.png').to route_to(
        'resource_files#update',
        user_id: 'admin@codeworkout.org',
        id: 'file.png')
    end

    it 'routes to #destroy' do
      expect(delete: '/users/admin@codeworkout.org/media/file.png').
        to route_to(
        'resource_files#destroy',
        user_id: 'admin@codeworkout.org',
        id: 'file.png')
    end

  end
end

require 'spec_helper'

RSpec.describe ExceptionHandler::ExceptionsController, type: :controller do
  routes { Rails.application.routes }

  describe 'GET #show with InvalidAuthenticityToken' do
    let(:csrf_exception) { ActionController::InvalidAuthenticityToken.new('Invalid authenticity token') }

    before do
      request.env['action_dispatch.exception'] = csrf_exception
    end

    it 'redirects to root_url with flash alert for HTML requests' do
      expect(ExceptionHandler::Exception).not_to receive(:new)

      get :show, params: { code: :unprocessable_entity }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Your session has expired. Please try signing in again.')
    end

    it 'returns JSON error for JSON / XHR requests' do
      request.env['HTTP_ACCEPT'] = 'application/json'
      expect(ExceptionHandler::Exception).not_to receive(:new)

      get :show, params: { code: :unprocessable_entity }, format: :json

      expect(response.status).to eq(422)
      json = JSON.parse(response.body)
      expect(json['error']).to include('session has expired')
    end
  end

  describe 'GET #show with other exceptions' do
    let(:routing_exception) { ActionController::RoutingError.new('Not found') }
    let(:mock_exception_model) { double('ExceptionHandler::Exception', status: 404, valid?: true, save: true) }

    before do
      request.env['action_dispatch.exception'] = routing_exception
      allow(ExceptionHandler::Exception).to receive(:new).and_return(mock_exception_model)
    end

    it 'processes standard exceptions without redirecting' do
      get :show, params: { code: :not_found }

      expect(response.status).to eq(404)
      expect(response).not_to be_redirect
    end
  end
end

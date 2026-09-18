require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def test_generate
      token = generate_lti_launch_token(params[:lms_instance_id])
      render plain: token
    end

    def test_lookup
      ctx = lti_context_for_token(params[:token])
      render json: ctx
    end
  end

  before do
    routes.draw do
      get 'test_generate' => 'anonymous#test_generate'
      get 'test_lookup' => 'anonymous#test_lookup'
    end
  end

  describe '#generate_lti_launch_token and #lti_context_for_token' do
    it 'generates a launch token and stores context in session' do
      get :test_generate, params: { lms_instance_id: 42 }
      token = response.body
      expect(token).to match(/^\d{8}$/)

      get :test_lookup, params: { token: token }
      json = JSON.parse(response.body)
      expect(json['lms_instance_id']).to eq('42')
    end

    it 'prunes oldest token when session has existing string-keyed contexts without raising comparison error' do
      # Simulate existing tokens with string keys as deserialized from cookie session
      session[:lti_contexts] = {
        '10000001' => { 'lms_instance_id' => 1, 'timestamp' => 100 },
        '10000002' => { 'lms_instance_id' => 2, 'timestamp' => 200 }
      }

      # Adding a 3rd token will trigger pruning of the oldest token (10000001)
      get :test_generate, params: { lms_instance_id: 3 }
      new_token = response.body

      expect(session[:lti_contexts].size).to eq(2)
      expect(session[:lti_contexts]).not_to have_key('10000001')
      expect(session[:lti_contexts]).to have_key('10000002')
      expect(session[:lti_contexts]).to have_key(new_token)
    end

    it 'handles malformed session entries gracefully when pruning' do
      session[:lti_contexts] = {
        '10000001' => nil,
        '10000002' => { 'lms_instance_id' => 2 } # missing timestamp
      }

      expect {
        get :test_generate, params: { lms_instance_id: 3 }
      }.not_to raise_error

      expect(session[:lti_contexts].size).to eq(2)
    end
  end

  describe 'rescue_from ActionController::InvalidAuthenticityToken' do
    controller do
      def test_csrf_error
        raise ActionController::InvalidAuthenticityToken
      end
    end

    before do
      routes.draw do
        root to: 'anonymous#test_generate'
        get 'test_csrf_error' => 'anonymous#test_csrf_error'
      end
    end

    it 'redirects to root_path with flash alert' do
      get :test_csrf_error
      expect(response).to redirect_to('/')
      expect(flash[:alert]).to include('session has expired')
    end
  end
end

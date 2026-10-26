require 'spec_helper'

describe HelpController, type: :controller do
  render_views

  describe 'GET #specifying_due_dates' do
    it 'renders the specifying_due_dates template successfully' do
      get :specifying_due_dates
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Instructor Guide: Specifying Due Dates')
      expect(response.body).to include('workout_attempts')
      expect(response.body).to include('workout_score_to_keep')
      expect(response.body).to include('exercise_score_to_keep')
      expect(response.body).to include('lms_assignment_url')
    end
  end

  describe 'GET #exercise_pools' do
    it 'renders the exercise_pools template successfully' do
      get :exercise_pools
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Instructor Guide: Randomized Exercise Pools')
      expect(response.body).to include('Add Exercise Pool')
      expect(response.body).to include('Draw')
      expect(response.body).to include('Points each')
    end
  end
end

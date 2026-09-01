# frozen_string_literal: true

require 'spec_helper'

RSpec.describe User, type: :model do
  describe '.lti_new_or_existing_user' do
    let(:email) { 'new_student@vt.edu' }
    let(:opts) do
      {
        lis_person_contact_email_primary: email,
        first_name: 'Test',
        last_name: 'Student'
      }
    end

    it 'returns existing user if user is found by email' do
      existing_user = FactoryBot.build_stubbed(:user, email: email)
      allow(User).to receive(:find_by).with(email: email).and_return(existing_user)

      result = User.lti_new_or_existing_user(opts)
      expect(result).to eq(existing_user)
    end

    it 'rescues RecordNotUnique and retrieves existing user on race condition' do
      existing_user = FactoryBot.build_stubbed(:user, email: email)

      # First call to find_by returns nil (user not found yet)
      # Second call after RecordNotUnique returns the existing user created concurrently
      allow(User).to receive(:find_by).with(email: email).and_return(nil, existing_user)

      new_user_instance = User.new(email: email, first_name: 'Test', last_name: 'Student')
      allow(User).to receive(:new).and_return(new_user_instance)
      allow(new_user_instance).to receive(:save!).and_raise(ActiveRecord::RecordNotUnique.new("Duplicate entry"))

      result = User.lti_new_or_existing_user(opts)
      expect(result).to eq(existing_user)
    end
  end
end

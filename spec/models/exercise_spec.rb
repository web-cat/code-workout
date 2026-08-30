# == Schema Information
#
# Table name: exercises
#
#  id                     :bigint           not null, primary key
#  experience             :integer          not null
#  is_public              :boolean          default(FALSE), not null
#  name                   :string(255)
#  question_type          :integer          not null
#  versions               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  current_version_id     :bigint
#  exercise_collection_id :bigint
#  exercise_family_id     :bigint
#  external_id            :string(255)
#  irt_data_id            :bigint
#
# Indexes
#
#  index_exercises_on_current_version_id      (current_version_id)
#  index_exercises_on_exercise_collection_id  (exercise_collection_id)
#  index_exercises_on_exercise_family_id      (exercise_family_id)
#  index_exercises_on_external_id             (external_id) UNIQUE
#  index_exercises_on_irt_data_id             (irt_data_id)
#  index_exercises_on_is_public               (is_public)
#
# Foreign Keys
#
#  exercises_current_version_id_fk  (current_version_id => exercise_versions.id)
#  exercises_exercise_family_id_fk  (exercise_family_id => exercise_families.id)
#  exercises_irt_data_id_fk         (irt_data_id => irt_data.id)
#  fk_rails_...                     (current_version_id => exercise_versions.id)
#  fk_rails_...                     (exercise_collection_id => exercise_collections.id)
#  fk_rails_...                     (exercise_family_id => exercise_families.id)
#  fk_rails_...                     (irt_data_id => irt_data.id)
#

require 'spec_helper'

describe Exercise do
  before :each do
    @admin = FactoryBot.create :admin, email: "admin_#{SecureRandom.hex(4)}@codeworkout.org"
    @user = FactoryBot.create :confirmed_user, email: "user_#{SecureRandom.hex(4)}@codeworkout.org"
  end

  context 'SLC items catalog generation' do
    it 'generates a valid JSON catalog for public exercises' do
      ex = FactoryBot.create :coding_exercise, is_public: true, name: 'Test Exercise', external_id: 'test-123', creator: @user
      
      filename = Rails.root.join('tmp', 'slc_catalog.json')
      Exercise.generate_slc_catalog(filename)
      
      expect(File.exist?(filename)).to be_truthy
      catalog = JSON.parse(File.read(filename))
      expect(catalog).to be_an(Array)
      
      item = catalog.find { |i| i['persistentID'] == 'test-123' }
      expect(item).not_to be_nil
      expect(item['catalog_type']).to eq('SLCItem')
      expect(item['title']).to eq('Test Exercise')
      expect(item['description']).to eq('Coding question')
      # The coding_exercise factory provides these tags: factorial, function, multiplication
      expect(item['keywords']).to include('factorial', 'function', 'multiplication')
      expect(item['iframe_url']).to eq("https://codeworkout.cs.vt.edu/gym/exercises/#{ex.id}/practice?lti_launch=true")
      expect(item['institution']).to eq(["Virginia Tech"])
      
      File.delete(filename) if File.exist?(filename)
    end
  end

  context 'creator edit permissions' do
    it 'should not be editable by the exercise creator' do
      ex = FactoryBot.build :mc_exercise
      expect(@user.cannot? :edit, ex).to be_truthy
    end

    it 'should be editable by an administrator' do
      ex = FactoryBot.build :coding_exercise
      expect(@admin.can? :edit, ex).to be_truthy
    end
  end
end

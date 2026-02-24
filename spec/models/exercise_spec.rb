# == Schema Information
#
# Table name: exercises
#
#  id                     :integer          not null, primary key
#  experience             :integer          not null
#  is_public              :boolean          default(FALSE), not null
#  name                   :string(255)
#  question_type          :integer          not null
#  versions               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  current_version_id     :integer
#  exercise_collection_id :integer
#  exercise_family_id     :integer
#  external_id            :string(255)
#  irt_data_id            :integer
#
# Indexes
#
#  exercises_irt_data_id_fk                   (irt_data_id)
#  index_exercises_on_exercise_collection_id  (exercise_collection_id)
#  index_exercises_on_exercise_family_id      (exercise_family_id)
#  index_exercises_on_external_id             (external_id) UNIQUE
#  index_exercises_on_is_public               (is_public)
#
# Foreign Keys
#
#  exercises_exercise_family_id_fk  (exercise_family_id => exercise_families.id)
#  exercises_irt_data_id_fk         (irt_data_id => irt_data.id)
#

require 'spec_helper'

describe Exercise do
  before :all do
    @admin = FactoryBot.build :admin
    @user = FactoryBot.build :confirmed_user
  end

  context 'SLC items catalog generation' do
    it 'generates a valid JSON catalog for public exercises' do
      # Create a public exercise using the factory which sets tags automatically
      ex = FactoryBot.create :coding_exercise, is_public: true, name: 'Test Exercise', external_id: 'test-123'
      
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
      expect(item['iframe_url']).to eq("https://codeworkout.cs.vt.edu/gym/exercises/#{ex.id}/practice")
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

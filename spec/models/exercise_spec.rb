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

describe Exercise, type: :model do
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
    it 'should not be editable by non-creator' do
      ex = FactoryBot.create :mc_exercise
      expect(@user.cannot? :edit, ex).to be_truthy
    end

    it 'should be editable by an administrator' do
      ex = FactoryBot.create :coding_exercise
      expect(@admin.can? :edit, ex).to be_truthy
    end
  end

  context 'attempt creation' do
    it 'creates and saves an attempt with prompt answers without foreign key violation' do
      ex = FactoryBot.create :coding_exercise, creator: @user
      version = ex.current_version
      attempt = version.new_attempt(user: @user)
      expect { attempt.save! }.not_to raise_error
      expect(attempt.persisted?).to be_truthy

      prompt = version.prompts.first
      pa = prompt.specific.new_answer
      pa.attempt = attempt
      pa.prompt = prompt
      pa.answer = 'public boolean cigarParty() { return true; }'
      expect { pa.save! }.not_to raise_error
      expect(pa.persisted?).to be_truthy
      expect(attempt.reload.prompt_answers.size).to eq(1)
    end
  end

  context '.search' do
    let(:admin_user) { FactoryBot.build_stubbed(:admin, id: 1) }
    let(:regular_user) { FactoryBot.build_stubbed(:confirmed_user, id: 2) }
    let(:owner_user) { FactoryBot.build_stubbed(:confirmed_user, id: 3) }

    let(:public_ex1) do
      FactoryBot.build_stubbed(
        :exercise,
        id: 101,
        name: 'Recursion Base Case',
        is_public: true
      )
    end

    let(:public_ex2) do
      FactoryBot.build_stubbed(
        :exercise,
        id: 102,
        name: 'Binary Tree Traversal',
        is_public: true
      )
    end

    let(:private_ex) do
      FactoryBot.build_stubbed(
        :exercise,
        id: 103,
        name: 'Secret Exam Exercise',
        is_public: false
      )
    end

    before :each do
      allow(public_ex1).to receive(:visible_to?).with(regular_user).and_return(true)
      allow(public_ex1).to receive(:visible_to?).with(admin_user).and_return(true)
      allow(public_ex2).to receive(:visible_to?).with(regular_user).and_return(true)
      allow(private_ex).to receive(:visible_to?).with(regular_user).and_return(false)
      allow(private_ex).to receive(:visible_to?).with(owner_user).and_return(true)
      allow(private_ex).to receive(:visible_to?).with(admin_user).and_return(true)
    end

    it 'returns exercises by X-prefixed ID (case-insensitive)' do
      relation = double('ExerciseRelation')
      allow(relation).to receive(:includes).and_return(relation)
      allow(relation).to receive(:order).and_return([public_ex1])
      allow(relation).to receive(:index_by).and_return({ 101 => public_ex1 })
      allow(relation).to receive(:each).and_yield(public_ex1)
      allow(Exercise).to receive(:where).with(id: [101]).and_return(relation)

      results = Exercise.search(['X101'], regular_user)
      expect(results).to eq([public_ex1])

      results_lower = Exercise.search(['x101'], regular_user)
      expect(results_lower).to eq([public_ex1])
    end

    it 'returns exercises by raw numeric ID and hash-prefixed ID' do
      relation = double('ExerciseRelation')
      allow(relation).to receive(:includes).and_return(relation)
      allow(relation).to receive(:order).and_return([public_ex1])
      allow(relation).to receive(:index_by).and_return({ 101 => public_ex1 })
      allow(relation).to receive(:each).and_yield(public_ex1)
      allow(Exercise).to receive(:where).with(id: [101]).and_return(relation)

      results_numeric = Exercise.search(['101'], regular_user)
      expect(results_numeric).to eq([public_ex1])

      results_hash = Exercise.search(['#101'], regular_user)
      expect(results_hash).to eq([public_ex1])
    end

    it 'returns multiple exercises by ID preserving requested order' do
      relation = double('ExerciseRelation')
      allow(relation).to receive(:includes).and_return(relation)
      allow(relation).to receive(:order).and_return([public_ex2, public_ex1])
      allow(relation).to receive(:index_by).and_return({ 102 => public_ex2, 101 => public_ex1 })
      allow(Exercise).to receive(:where).with(id: [102, 101]).and_return(relation)

      results = Exercise.search(['X102', 'X101'], regular_user)
      expect(results).to eq([public_ex2, public_ex1])
    end

    it 'filters out private exercises for unauthorized users' do
      relation = double('ExerciseRelation')
      allow(relation).to receive(:includes).and_return(relation)
      allow(relation).to receive(:order).and_return([private_ex])
      allow(relation).to receive(:index_by).and_return({ 103 => private_ex })
      allow(Exercise).to receive(:where).with(id: [103]).and_return(relation)

      other_results = Exercise.search(['X103'], regular_user)
      expect(other_results).to eq(Exercise.none)

      owner_results = Exercise.search(['X103'], owner_user)
      expect(owner_results).to eq([private_ex])

      admin_results = Exercise.search(['X103'], admin_user)
      expect(admin_results).to eq([private_ex])
    end

    it 'caps candidate and return list at MAX_SEARCH_RESULTS (50)' do
      expect(Exercise::MAX_SEARCH_RESULTS).to eq(50)
      many_ids = (1..60).map { |n| "X#{n}" }

      relation = double('ExerciseRelation')
      allow(relation).to receive(:includes).and_return(relation)
      allow(relation).to receive(:order).and_return([])
      allow(relation).to receive(:index_by).and_return({})
      expect(Exercise).to receive(:where).with(id: (1..50).to_a).and_return(relation)

      Exercise.search(many_ids, admin_user)
    end
  end
end



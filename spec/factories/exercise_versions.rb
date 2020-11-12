# == Schema Information
#
# Table name: exercise_versions
#
#  id                  :integer          not null, primary key
#  text_representation :text(16777215)
#  version             :integer          not null
#  created_at          :datetime
#  updated_at          :datetime
#  creator_id          :integer
#  exercise_id         :integer          not null
#  irt_data_id         :integer
#  stem_id             :integer
#
# Indexes
#
#  exercise_versions_creator_id_fk         (creator_id)
#  exercise_versions_irt_data_id_fk        (irt_data_id)
#  index_exercise_versions_on_exercise_id  (exercise_id)
#  index_exercise_versions_on_stem_id      (stem_id)
#
# Foreign Keys
#
#  exercise_versions_creator_id_fk   (creator_id => users.id)
#  exercise_versions_exercise_id_fk  (exercise_id => exercises.id)
#  exercise_versions_irt_data_id_fk  (irt_data_id => irt_data.id)
#  exercise_versions_stem_id_fk      (stem_id => stems.id)
#

FactoryBot.define do
  factory :exercise_version do
  end
end

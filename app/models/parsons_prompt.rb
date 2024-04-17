# == Schema Information
#
# Table name: parsons_prompts
#
#  id                  :integer          not null, primary key
#  assets              :text(65535)
#  instructions        :text(65535)
#  title               :text(65535)
#  created_at          :datetime
#  updated_at          :datetime
#  exercise_id         :string(255)
#  exercise_version_id :integer          not null
#
# Indexes
#
#  fk_rails_40d6ef5b4f  (exercise_version_id)
#
# Foreign Keys
#
#  fk_rails_...  (exercise_version_id => exercise_versions.id)
#

class ParsonsPrompt < ActiveRecord::Base
    belongs_to :parsons
    belongs_to :exercise_version

    serialize :assets, JSON
  end

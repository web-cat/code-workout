# == Schema Information
#
# Table name: ownerships
#
#  id                  :integer          not null, primary key
#  filename            :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  exercise_version_id :integer
#  resource_file_id    :integer
#
# Indexes
#
#  index_ownerships_on_exercise_version_id  (exercise_version_id)
#  index_ownerships_on_filename             (filename)
#  index_ownerships_on_resource_file_id     (resource_file_id)
#
# Foreign Keys
#
#  fk_rails_...  (exercise_version_id => exercise_versions.id)
#  fk_rails_...  (resource_file_id => resource_files.id)
#

class Ownership < ActiveRecord::Base
  belongs_to :resource_file
  belongs_to :exercise_version
end

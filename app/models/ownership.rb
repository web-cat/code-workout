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
  require 'tempfile'


  def self.create_ownership(e, fileList, files, current_user)
    ex_ver = e.exercise_versions.first
    # inherit ownertable
    if !e.exercise_versions.offset(1).first.nil?
      oldversion = e.exercise_versions.offset(1).first
      oldversion.ownerships.each do |ownerentry|
        if fileList != "" 
          if fileList.include? ownerentry.filename
            ownertable = ex_ver.ownerships.create(filename: ownerentry.filename, resource_file_id: ownerentry.resource_file_id)
          end
        end
      end
    end
    unless files.nil? 
      files.each do |file|
        file.original_filename = file.original_filename.gsub(/ /, '_')
        tempfile = Tempfile.create{file}
        hashval = Digest::MD5.hexdigest File.read "#{tempfile.path}"
        if ResourceFile.all.where(hashval: hashval).exists?
          ownertable = ex_ver.ownerships.create(filename: file.original_filename,resource_file_id: ResourceFile.all.where(hashval: hashval).first.id)
        else       
          res = ex_ver.resource_files.create!(user_id: current_user.id,filename:file, hashval:hashval)
          ownertable = res.ownerships.last
          ownertable.filename = file.original_filename
          ownertable.save
        end
      end
    end
  end
end

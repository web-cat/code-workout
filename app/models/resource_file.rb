# == Schema Information
#
# Table name: resource_files
#
#  id         :integer          not null, primary key
#  filename   :string(255)
#  token      :string(255)      default(""), not null
#  user_id    :integer          not null
#  public     :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_resource_files_on_token    (token)
#  index_resource_files_on_user_id  (user_id)
#

# =============================================================================
# Represents a file uploaded by a user for use in exercises, such as an
# image or video file.
#
class ResourceFile < ActiveRecord::Base
  include Tokenable #for unique non-serial url tokens


  #~ Relationships ............................................................

  has_and_belongs_to_many :exercise_versions
  belongs_to :user


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :token, presence: true


  #~ Hooks ....................................................................

  before_validation :token

  STORAGE_DIR = 'usr/resources/resource_files'


  #~ Public instance methods ..................................................

  # -------------------------------------------------------------
  #for pretty URLs
  def to_param
  	token
  end


  # -------------------------------------------------------------
  def url
   STORAGE_DIR + '/' + self.filename.to_s
  end


  # -------------------------------------------------------------
  def save_file(upload)
    ext = File.extname(upload.original_filename) || ""
  	renamed = self.token + ext
  	path = File.join(STORAGE_DIR, renamed)
  	self.filename = renamed
  	File.open(path, 'wb') { |f| f.write(upload.tempfile.read) }
  	self
  end
end

# == Schema Information
#
# Table name: resource_files
#
#  id         :integer          not null, primary key
#  filename   :string(255)
#  hashval    :string(255)
#  public     :boolean          default(TRUE)
#  token      :string(255)      default(""), not null
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer          not null
#
# Indexes
#
#  index_resource_files_on_hashval  (hashval)
#  index_resource_files_on_token    (token)
#  index_resource_files_on_user_id  (user_id)
#
# Foreign Keys
#
#  resource_files_user_id_fk  (user_id => users.id)
#

# =============================================================================
# Represents a file uploaded by a user for use in exercises, such as an
# image or video file.
#
class ResourceFile < ActiveRecord::Base
  include Tokenable #for unique non-serial url tokens


  #~ Relationships ............................................................

  has_many :ownerships
  has_many :exercise_versions, through: :ownerships
  belongs_to :user


  #~ Validation ...............................................................

  validates :user, presence: true
  # validates :token, presence: true

  #~ Validation ...............................................................
  mount_uploader :filename, FileUploader

  #~ Hooks ....................................................................

  before_validation :token

  # STORAGE_DIR = 'usr/resources/resource_files'
  UPLOAD_PATH = '/uploads/' + ResourceFile.to_s.underscore


  #~ Public instance methods ..................................................

  # -------------------------------------------------------------
  #for pretty URLs
  def to_param
  	token
  end


  # -------------------------------------------------------------
  # Return the ResourceFile object associated with a specified hash code
  def self.for_hash(hash)
    ResourceFile.find_by(hashval: hash)
  end


  # -------------------------------------------------------------
  # Return the ResourceFile object associated with a specified file upload,
  # creating one if necessary
  def self.for_upload(upload, user)
    tempfile = Tempfile.create { upload }
    hashcode = Digest::MD5.hexdigest(File.read(tempfile.path))
    # FIXME: need to close the tempfile and delete it
    existing = for_hash(hashcode)
    if !existing
      existing = ResourceFile.create!(
        filename: upload,
        hashval: hashcode,
        user: user
      )
    end
    existing
  end


  # -------------------------------------------------------------
  # FIXME: This is the actual file name using the token value, but this
  # method is bogus. The value /should/ be stored in the filename attribute,
  # but the filename attribute is only the file extension, not the full file
  # name(!) This method can be fixed when the filename attribute gets fixed
  def tokenized_file_name
    self.token + self.read_attribute(:filename)
  end


  # -------------------------------------------------------------
  def url
   UPLOAD_PATH + '/' + self.tokenized_file_name
  end


  # -------------------------------------------------------------
  # FIXME: This is old, defunct code from before the use of carrier wave.
  # It may be useful again once we move file storage out of the /public
  # assets folder.
  def save_file(upload)
    ext = File.extname(upload.original_filename) || ""
  	renamed = self.token + ext
    # FIXME: this "path" reproduces what is in the url() method. Why?
  	path = File.join(STORAGE_DIR, renamed)
  	self.filename = renamed
  	File.open(path, 'wb') { |f| f.write(upload.tempfile.read) }
  	self
  end
end

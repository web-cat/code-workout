class ResourceFile < ActiveRecord::Base
  include Tokenable #for unique non-serial url tokens
  
  has_and_belongs_to_many :exercises
  belongs_to :user

  before_validation :token

  STORAGE_DIR = "public/resource"

  #for pretty URLs
  def to_param
  	"#{token}"
  end

  def url
   STORAGE_DIR +  self.filename.to_s
  end

  def save_file(upload)
    ext = File.extname(upload['file'].original_filename) || ""
  	renamed = self.token + ext
  	path = File.join(STORAGE_DIR, renamed)
  	self.filename = renamed
  	File.open(path, "wb") { |f| f.write(upload['file'].resourcefile) }  
  end
end
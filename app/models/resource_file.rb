class ResourceFile < ActiveRecord::Base
  include Tokenable #for unique non-serial url tokens
  
  has_and_belongs_to_many :exercises
  belongs_to :user
  
  STORAGE_DIR = "public/resource"

  #for pretty URLs
  def to_param
  	"#{token}"
  end

  def self.save(upload)
  	ext = File.extname(upload['file'].original_filename)
  	renamed = self.token + ext
  	path = File.join(STORAGE_DIR, renamed)
  	File.open(path, "wb") { |f| f.write(upload['file'].resourcefile) }
  end
end
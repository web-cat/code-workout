#from http://stackoverflow.com/questions/6021372/best-way-to-create-unique-token-in-rails 
# app/models/concerns/tokenable.rb
module Tokenable extend ActiveSupport::Concern

  included do
    before_create :generate_token
  end

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(token: random_token)
    end
  end
end
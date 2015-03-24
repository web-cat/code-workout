# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  display_name :string(255)
#  url_part     :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Organization < ActiveRecord::Base

  #~ Relationships ............................................................

  has_many :courses, inverse_of: :organization


  #~ Hooks ....................................................................

  before_validation :set_url_part


  #~ Validation ...............................................................

  validates :display_name, presence: true
  validates :url_part,
    format: {
      with: /[a-z0-9\-_.]+/,
      message: 'must consist only of letters, digits, hyphens (-), ' \
        'underscores (_), and periods (.).'
    },
    uniqueness: { case_sensitive: false }


  #~ Private instance methods .................................................

  private

  # -------------------------------------------------------------
  def set_url_part
    if url_part
      self.url_part = url_part.downcase
    end
  end

end

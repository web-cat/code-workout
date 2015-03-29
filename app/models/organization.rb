# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  url_part   :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_organizations_on_url_part  (url_part)
#

class Organization < ActiveRecord::Base

  #~ Relationships ............................................................

  has_many :courses, inverse_of: :organization, dependent: :destroy


  #~ Hooks ....................................................................

  before_validation :set_url_part


  #~ Validation ...............................................................

  validates :name, presence: true
  validates :url_part, presence: true,
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
    self.url_part = url_part_safe(url_part || name)
  end

end

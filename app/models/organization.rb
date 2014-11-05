# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  display_name :string(255)      not null
#  url_part     :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_organizations_on_display_name  (display_name) UNIQUE
#  index_organizations_on_url_part      (url_part) UNIQUE
#

class Organization < ActiveRecord::Base

  #~ Relationships ............................................................

  has_many :courses


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

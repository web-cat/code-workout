# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  name         :string(255)      default(""), not null
#  created_at   :datetime
#  updated_at   :datetime
#  abbreviation :string(255)
#  slug         :string(255)      default(""), not null
#  is_hidden    :boolean          default(FALSE)
#
# Indexes
#
#  index_organizations_on_slug  (slug) UNIQUE
#

# =============================================================================
# Represents a university, college, school, or other organization that
# has courses.
#
class Organization < ActiveRecord::Base
  extend FriendlyId
  friendly_id :abbreviation, use: :history

  #~ Relationships ............................................................

  has_many :courses,
    -> { order('number asc') },
    inverse_of: :organization,
    dependent: :destroy


  #~ Validation ...............................................................

  validates :name, presence: true,
    uniqueness: { case_sensitive: false }
  validates :abbreviation, presence: true,
    uniqueness: { case_sensitive: false }


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Converts a string into a book-like title, without capitalizing
    # articles or prepositions.  Note: this is different than the rails
    # titleize method in that it does not capitalize some words.  It is
    # also different than "correct" book titleizing, since it does not
    # capitalize the first word if it is an article (because we wouldn't
    # want to include it in an abbreviation), or ensure that the word "I"
    # is capitalized (because we don't expect that to appear in an org
    # name).
    def titleize(text)
      stop_words = %w(and or but in on to from with the a an)
      text.downcase.split.map{ |w|
        stop_words.include?(w) ? w : w.capitalize }.join(' ')
    end


    # -------------------------------------------------------------
    # Convert a properly capitalized name into an acronym (i.e.,
    # "Virginia Tech" => "VT") by pulling out only the capital letters.
    def acronym(text)
      titleize(text).scan(/[[:upper:]]/).join
    end


    # -------------------------------------------------------------
    def set_abbreviation_if_necessary
      if abbreviation.blank?
        self.abbreviation = acronym(name)
      end
    end


    # -------------------------------------------------------------
    def should_generate_new_friendly_id?
      set_abbreviation_if_necessary
      slug.blank? || abbreviation_changed?
    end

end

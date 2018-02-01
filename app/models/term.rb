# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  season     :integer          not null
#  starts_on  :date             not null
#  ends_on    :date             not null
#  year       :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  slug       :string(255)      default(""), not null
#
# Indexes
#
#  index_terms_on_slug             (slug) UNIQUE
#  index_terms_on_year_and_season  (year,season)
#

# =============================================================================
# Represents an academic term or semester, which indicates the time period
# for one or more course offerings.
#
class Term < ActiveRecord::Base
  extend FriendlyId
  friendly_id :display_name, use: :history

  #~ Relationships ............................................................

  has_many :course_offerings, inverse_of: :term, dependent: :destroy

  # Orders terms in descending order (latest time first).
  # default_scope { order('ends_on desc') }
  default_scope { order('year desc, season desc') }


  #~ Constants ................................................................

  # Hard-coded season names. It is assumed that these names contain
  # letters and spaces only -- no numbers. For example, the Summer
  # terms are denoted with Roman numerals instead of Arabic digits.
  # This is so that when they are converted into a path component
  # and combined with a year (e.g., 'summerii2012'), there is no
  # ambiguity as to where the season and year are separated.
  SEASONS = {
    'Spring' => 100,
    'Summer I' => 200,
    'Summer II' => 300,
    'Fall' => 400,
    'Winter' => 500
  }

  # Season names converted to lowercase with spaces removed.
  SEASON_PATH_NAMES = SEASONS.each_with_object({}) do |(k, v), hash|
    new_key = k.downcase.gsub(/\s+/, '')
    hash[new_key] = v
  end


  #~ Validation ...............................................................

  validates_presence_of :season, :year, :starts_on, :ends_on, :slug


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.season_name(season)
    SEASONS.rassoc(season).first
  end


  # -------------------------------------------------------------
  def self.current_term
    result = Term.
      where('starts_on <= :now and :now <= ends_on', now: Date.today).
      first
    return result ? result : Term.first
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def contains?(date_or_time)
    starts_on <= date_or_time && date_or_time < ends_on
  end


  # -------------------------------------------------------------
  def now?
    contains?(DateTime.now)
  end


  # -------------------------------------------------------------
  def season_name
    self.class.season_name(season)
  end


  # -------------------------------------------------------------
  def display_name
    "#{season_name} #{year}"
  end


  # -----------------------------------------
  def self.time_heuristic(date_string)
    if date_string.nil?
      puts 'INVALID Use of time_heuristic'
      return 0
    else
      date_split = date_string.split("-")
      if date_split[1]
        date_year = date_split[0]
        date_month = date_split[1]
        date_day = date_split[2]
        return date_year * 100.0 + date_month * 1.0 + date_day * 0.01
      else
        puts 'INVALID date_string format'
        return 0
      end
    end
  end


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    def should_generate_new_friendly_id?
      slug.blank? || season_changed? || year_changed?
    end

end

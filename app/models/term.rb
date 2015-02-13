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
#
# Indexes
#
#  index_terms_on_starts_on  (starts_on)
#

class Term < ActiveRecord::Base

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

  # Orders terms in descending order (latest time first).
  scope :latest_first, -> { order('year desc, season desc') }


  #~ Validation ...............................................................

  validates :season, presence: true
  validates :year, presence: true
  validates :starts_on, presence: true
  validates :ends_on, presence: true


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.season_name(season)
    SEASONS.rassoc(season).first
  end


  # -------------------------------------------------------------
  def self.from_path_component(path)
    if path =~ /([a-z]+)-(\d+)/
      season = SEASON_PATH_NAMES[$1]
      year = $2
      where(season: season, year: year)
    else
      where('1 = 0')
    end
  end

  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def contains?(date_or_time)
    # TODO We need to make sure time zones are properly handled, probably!

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
      puts "INVALID Use of time_heuristic"
      return 0
    else
      date_split = date_string.split("-")
      if date_split[1]       
        date_year = date_split[0]
        date_month = date_split[1]
        date_day = date_split[2]
        return date_year * 100.0 + date_month * 1.0 + date_day*0.01    
      else
        puts "INVALID date_string format"
        return 0
      end  
    end
  end  
   

  # -------------------------------------------------------------
  def url_part
    "#{SEASON_PATH_NAMES.rassoc(season).first}-#{year}"
  end

end

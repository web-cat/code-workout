# == Schema Information
#
# Table name: courses
#
#  id              :integer          not null, primary key
#  name            :string(255)      default(""), not null
#  number          :string(255)      default(""), not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  creator_id      :integer
#  slug            :string(255)      default(""), not null
#  user_group_id   :integer
#  is_hidden       :boolean          default(FALSE)
#
# Indexes
#
#  index_courses_on_organization_id  (organization_id)
#  index_courses_on_slug             (slug)
#  index_courses_on_user_group_id    (user_group_id)
#

# =============================================================================
# Represents a course at a university; akin to the course's catalog
# description.  A course may have one or more course offerings in any
# specific term.
#
class Course < ActiveRecord::Base
  extend FriendlyId
  friendly_id :number_without_spaces, use: [:history, :scoped],
    scope: :organization


  #~ Relationships ............................................................

  belongs_to  :organization, inverse_of: :courses
  has_many    :course_offerings, inverse_of: :course, dependent: :destroy
  # Associating with exercises through course_exercises
  has_many    :course_exercises, inverse_of: :course, dependent: :destroy
  has_many    :exercises, through: :course_exercises
  # Associating with user groups
  belongs_to :user_group, inverse_of: :course
  #Kaminari for the show method
  paginates_per 100

  accepts_nested_attributes_for :course_offerings, allow_destroy: true


  #~ Validation ...............................................................

  validates_presence_of :name, :number, :organization


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.search(terms)
    resultant = []
    term_array = terms.split
    term_array.each do |term|
      term = "%" + term + "%"
      Course.where("name LIKE ?",term).find_each do |course|
        resultant<<course.id
      end
    end

    return resultant
  end

  # --------------------------------------------------------------------
  # Throw an error if slug is specified without specifying organization.
  # This overrides find_by from ActiveRecord. Also affects find_by!
  def self.find_by(*args)
    kwargs = args[0]

    # Check if slug is included
    if kwargs.is_a?(Hash) # Args were specified as keywords
      has_slug = kwargs.key?(:slug)
    else # Args were specified as strings and interpolated values
      has_slug = args.any? { |arg| 
        arg.include?('slug')
      }
    end

    # Check if organization is included
    if kwargs.is_a?(Hash) # Args were specified as keywords
      has_org = kwargs.key?(:organization) || kwargs.key?(:organization_id)
    else # Args were specified as strings and interpolated values
      has_org = args.any? { |arg| 
        arg.include?('organization') ||
        arg.include?('organization_id')
      }
    end

    if has_slug && !has_org
      raise ArgumentError, 'If slug is specified, organization ' \
        'or organization_id must also be specified.'
    end

    super(*args)
  end

  # -------------------------------------------------------------
  def display_name
    number_and_name
  end


  # -------------------------------------------------------------
  def number_and_name
    "#{number}: #{name}"
  end


  # -------------------------------------------------------------
  def number_and_org
    "#{number} (#{organization.abbreviation})"
  end


  # -------------------------------------------------------------
  def number_and_organization
    "#{number} (#{organization.name})"
  end


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    def number_without_spaces
      number.gsub(/\s/, '')
    end


    # -------------------------------------------------------------
    def should_generate_new_friendly_id?
      slug.blank? || number_changed?
    end

end

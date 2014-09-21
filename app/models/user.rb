# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  global_role_id         :integer
#

class User < ActiveRecord::Base

  include Gravtastic
  gravtastic secure: true, default: 'monsterid'

  delegate    :can?, :cannot?, to: :ability

  belongs_to  :global_role
#  has_many    :authentications
#  has_many    :activity_logs
  has_many    :course_enrollments
  has_many    :course_offerings, through: :course_enrollments
  has_many    :attempts
  has_many    :tag_user_scores
  has_many    :resource_files
#  has_many    :assignment_offerings, through: :course_offerings


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable
#    ,
#    :confirmable, :omniauthable

  before_create :set_default_role

  paginates_per 100

  scope :search, lambda { |query|
    unless query.blank?
      arel = self.arel_table
      pattern = "%#{query}%"
      where(arel[:email].matches(pattern).or(
            arel[:last_name].matches(pattern)).or(
            arel[:last_name].matches(pattern)))
    end
  }

  scope :alphabetical, -> { order('last_name asc, first_name asc, email asc') }


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.all_emails(prefix = '')
    self.uniq.where(self.arel_table[:email].matches(
      "#{prefix}%")).reorder('email asc').pluck(:email)
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
#  def storage_path
#    File.join(
#      SystemConfiguration.first.storage_path, 'users', email)
#  end


  # -------------------------------------------------------------
  def ability
    @ability ||= Ability.new(self)
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all of the CourseOfferings that
  # this user can manage.
  #
  # Returns a relation representing all of the CourseOfferings that this
  # user can manage
  #
  def managing_course_offerings
    # It seems like I should have been able to do this through the
    # course_offerings association directly somehow, but writing
    # course_offerings.joins(...) resulted in a double-join. This seems
    # to work correctly instead.
    CourseOffering.joins(:course_enrollments => :course_role).where(
      course_enrollments: { user_id: id },
      course_roles: { can_manage_course: true })
  end


  # -------------------------------------------------------------
  # Gets the user's "display name", which is their full name if it is in the
  # database, otherwise it is their e-mail address.
  def display_name
    last_name.blank? ?
      (first_name.blank? ? email : first_name) :
      (first_name.blank? ? last_name : (first_name + ' ' + last_name))
  end


  # -------------------------------------------------------------
  # Gets the username (without the domain) of the e-mail address, if possible.
  def email_without_domain
    if email =~ /(^[^@]+)@/
      $1
    else
      email
    end
  end


  private

  # -------------------------------------------------------------
  # Sets the first user's role as administrator and subsequent users
  # as student (note: be sure to run rake db:seed to create these roles)
  def set_default_role
    if User.count == 0
      self.global_role = GlobalRole.administrator
    elsif self.global_role.nil?
      self.global_role = GlobalRole.regular_user
    end
  end


  # -------------------------------------------------------------
  # Overrides the built-in password required method to allow for users
  # to be updated without errors
  # taken from: http://www.chicagoinformatics.com/index.php/2012/09/user-administration-for-devise/
  def password_required?
    (!password.blank? && !password_confirmation.blank?) || new_record?
  end

end

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
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  global_role_id         :integer
#  name                   :string(255)
#  avatar                 :string(255)
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_global_role_id        (global_role_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base

  include Gravtastic
  gravtastic secure: true, default: 'monsterid'

  delegate    :can?, :cannot?, to: :ability

  belongs_to  :global_role
#  has_many    :authentications
#  has_many    :activity_logs
  has_many    :course_enrollments, inverse_of: :user, dependent: :destroy
  has_many    :course_offerings, through: :course_enrollments
  has_many    :workouts, through: :workout_scores
  has_many    :workout_scores, inverse_of: :user, dependent: :destroy
  has_many    :attempts
  has_many    :tag_user_scores
  has_many    :resource_files
  has_many    :identities, inverse_of: :user, dependent: :destroy
#  has_many    :assignment_offerings, through: :course_offerings
#   Below two relationships deemed unnecessary for the time being
#  has_many :test_case_results
#  has_many :test_cases, through: :test_case_results


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :omniauth_providers => [:facebook, :google_oauth2]
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
  #    SystemConfiguration.first.storage_path, 'users', email)
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


  # -------------------------------------------------------------
  def avatar_url
    avatar || gravatar_url
  end


  # -------------------------------------------------------------
  # Omni auth for Facebook and Google Users
  def self.from_omniauth(auth, guest = nil)
    user = nil
    identity = Identity.where(provider: auth.provider, uid: auth.uid).first
    if identity
      user = identity.user
    else
      user = User.where(email: auth.info.email).first
      if !user
        user = User.create(
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          email: auth.info.email,
          password: Devise.friendly_token[0, 20])
      end
      user.identities.create(provider: auth.provider, uid: auth.uid)
    end

    if user
      user.first_name ||= auth.info.first_name
      user.last_name ||= auth.info.last_name
      user.email ||= auth.info.email
      user.avatar ||= auth.info.image
      if user.changed?
        user.save
      end
    end
    return user
  end


  #~ Private instance methods .................................................
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
  # taken from: http://www.chicagoinformatics.com/index.php/2012/09/
  # user-administration-for-devise/
  def password_required?
    (!password.blank? && !password_confirmation.blank?) || new_record?
  end

end

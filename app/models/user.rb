# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      default(""), not null
#  encrypted_password       :string(255)      default(""), not null
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0), not null
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  confirmation_token       :string(255)
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  created_at               :datetime
#  updated_at               :datetime
#  first_name               :string(255)
#  last_name                :string(255)
#  global_role_id           :integer          not null
#  avatar                   :string(255)
#  slug                     :string(255)      default(""), not null
#  current_workout_score_id :integer
#  time_zone_id             :integer
#
# Indexes
#
#  index_users_on_confirmation_token        (confirmation_token) UNIQUE
#  index_users_on_current_workout_score_id  (current_workout_score_id) UNIQUE
#  index_users_on_email                     (email) UNIQUE
#  index_users_on_global_role_id            (global_role_id)
#  index_users_on_reset_password_token      (reset_password_token) UNIQUE
#  index_users_on_slug                      (slug) UNIQUE
#  index_users_on_time_zone_id              (time_zone_id)
#

# =============================================================================
# Represents a single user account on the system.
#
class User < ActiveRecord::Base
  include Gravtastic
  gravtastic secure: true, default: 'monsterid'

  extend FriendlyId
  friendly_id :email_or_id


  #~ Relationships ............................................................
  belongs_to  :global_role
  belongs_to  :time_zone
#  has_many    :authentications
#  has_many    :activity_logs
  has_many    :course_enrollments,
    -> { includes :course_role, :course_offering },
   inverse_of: :user, dependent: :destroy
  has_many    :course_offerings, through: :course_enrollments
  has_many    :workout_scores, -> { includes :workout },
    inverse_of: :user, dependent: :destroy
  has_many    :workouts, through: :workout_scores
  has_many    :exercise_owners, inverse_of: :owner
  has_many    :exercises, through: :exercise_owners
  has_many    :workout_owners, inverse_of: :owner
  has_many    :workouts, through: :workout_owners
  has_many    :attempts, dependent: :destroy
  has_many    :tag_user_scores, -> { includes :tag },
    inverse_of: :user, dependent: :destroy
  has_many    :resource_files, inverse_of: :user
  has_many    :identities, inverse_of: :user, dependent: :destroy
  has_many    :student_extensions
  has_many    :workout_offerings, through: :student_extensions

  belongs_to  :current_workout_score, class_name: 'WorkoutScore'
  has_many    :test_case_results, inverse_of: :user, dependent: :destroy
  has_many    :lti_identities

  has_many :memberships
  has_many :user_groups, through: :memberships
  has_many :group_access_requests, inverse_of: :user
  has_one :exercise_collection

  accepts_nested_attributes_for :memberships
  #~ Hooks ....................................................................

  delegate :can?, :cannot?, to: :ability

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, and :timeoutable
  devise :database_authenticatable, :omniauthable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,  # :confirmable,
    :omniauth_providers => [:facebook, :google_oauth2, :cas]

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
  scope :visible_to_user, -> (u) { joins{course_enrollments.outer}.
    where{ (id == u.id) |
    (course_enrollments.course_role_id != CourseRole::STUDENT_ID) } }

  attr_accessor :skip_password_validation


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.all_emails(prefix = '')
    self.uniq.where(self.arel_table[:email].matches(
      "#{prefix}%")).reorder('email asc').pluck(:email)
  end


  # -------------------------------------------------------------
  def self.not_in_group(user_group)
    if user_group.nil?
      User.all
    else
      User.where.not(id: user_group.users.flat_map(&:id))
    end
  end


  # -------------------------------------------------------------
  def self.account_pairs
    incomplete_emails = User.where(User.arel_table[:email].
      does_not_match('%@%')).
      where("`id` in (?)", LtiIdentity.all.map(&:user_id))

    duplicate_pairs = {}
    incomplete_emails.flat_map(&:email).each do |e|
      duplicate_account = User.where("email like '#{e}@%'").limit(1).first
      if duplicate_account
        duplicate_pairs[e] = duplicate_account.email
      end
    end

    return duplicate_pairs
  end


  # -------------------------------------------------------------
  # Given a hash representing pairs of email, for each pair,
  # decide which one takes precedence. Then merge the second
  # user into it
  #
  # The pairs are in order: { 'user': 'user@domain.com' }
  def self.merge_account_pairs(pairs)
    #pairs = self.account_pairs
    pairs.each do |incomplete_email, complete_email|
      user1 = User.find_by(email: incomplete_email)
      user2 = User.find_by(email: complete_email)

      sorted = [user1, user2].sort do |a, b|
        if a.attempts.count > b.attempts.count
          1
        elsif b.attempts.count > 0
          -1
        elsif a.course_enrollments.count > b.course_enrollments.count
          1
        elsif b.course_enrollments.count > 0
          -1
        else
          a.sign_in_count <=> b.sign_in_count
        end
      end
      merge_master = sorted.last
      merge_master.merge_with(sorted.first, user2.email)
    end
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
  def is_a_member_of?(user_group)
    user_groups.include?(user_group)
  end


  # -------------------------------------------------------------
  def access_request_for(user_group)
    GroupAccessRequest.find_by user: self, user_group: user_group
  end

  # -------------------------------------------------------------
  # Public: Gets a relation representing all of the CourseOfferings that
  # this user can manage. If a course and term are passed,
  # filters the list by course and term as well.
  #
  # Returns a relation representing all of the CourseOfferings that this
  # user can manage
  # params = {term, course} (optional)
  #
  def managed_course_offerings(options = {})
    course = options[:course]
    term = options[:term]
    if course.nil? && term.nil?
      course_enrollments.where(course_roles: { can_manage_course: true }).
        map(&:course_offering)
    elsif course.nil?
      course_enrollments.joins(:course_offering).
        where(course_roles:
          { can_manage_course: true }, course_offering:
            { term: term }
        ).map(&:course_offering)
    elsif term.nil?
      course_enrollments.joins(:course_offering).
        where(course_roles:
          { can_manage_course: true }, course_offering:
            { course: course }
        ).map(&:course_offering)
    else
      course_enrollments.joins(:course_offering).
        where(course_roles:
          { can_manage_course: true }, course_offering:
            { course: course, term: term }
        ).map(&:course_offering)
    end
  end


  # -------------------------------------------------------------
  def instructor_course_offerings
    course_enrollments.where(course_role: CourseRole.instructor).
      map(&:course_offering)
  end


  # -------------------------------------------------------------
  def grader_course_offerings
    course_enrollments.where(course_role: CourseRole.grader).
      map(&:course_offering)
  end


  # -------------------------------------------------------------
  def student_course_offerings
    course_enrollments.where(course_role: CourseRole.student).
      map(&:course_offering)
  end


  # -------------------------------------------------------------
  # Get all workout offerings from course offerings that the
  # user manages, for the specified course and term
  def managed_workout_offerings_in_term(workout, course, term)
    if !term.nil?
      enrollments = course_enrollments.
        joins(course_offering: :workout_offerings).
        where(course_roles:
          { can_manage_course: true }, course_offering:
            { course: course, term: term }
        )
      else
        enrollments = course_enrollments.
          joins(course_offering: :workout_offerings).
          where(course_roles:
            { can_manage_course: true }, course_offering:
              { course: course }
            )
      end

      enrollments.map { |e|
        if workout.kind_of?(String)
          workouts_with_name = Workout.where('lower(name) = ?', workout)
          e.course_offering.workout_offerings.where('workout_id in ?', workouts_with_name.select(:id))
        else
          e.course_offering.workout_offerings.where(workout: workout)
        end
      }
  end


  # -------------------------------------------------------------
  # Get all workouts that have been offered in a course
  # for which the user has been an instructor AND for which
  # the user is in the privileged group
  # Simply being an instructor in the course is not enough,
  # to prevent users from simply creating `fake` course_offerings
  # to get access to course materials
  def managed_workouts
    course_enrollments.
      joins(course_offering: { course: { user_group: :memberships } }).
      where(course_roles:
        { can_manage_course: true }, course_offering:
          { course:
            { user_group:
              { memberships:
                { user: self } } } }
      ).flat_map { |e| e.course_offering.workout_offerings }.map(&:workout)
  end


  # -------------------------------------------------------------
  def course_offerings_for_term(term, course)
    conditions = { term: term, 'users.id' => self }
    if course
      conditions[:course] = course
    end
    CourseOffering.
      joins(course_enrollments: :user).
      where(conditions).
      distinct
  end


  # -------------------------------------------------------------
  def courses_for_term(term)
    Course.
      joins(course_offerings: { course_enrollments: :user }).
      where('course_offerings.term_id' => term, 'users.id' => self).
      distinct
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
  # Gets the user's "label name", which is their last name, first name, or
  # email_without_domain, in decreasing order of preference. For use in
  # auto-generated course_offering labels
  def label_name
    last_name.blank? ?
      (first_name.blank? ? email_without_domain : first_name) : last_name
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
  def avatar_url(options = {})
    self.avatar.blank? ? gravatar_url(options) : self.avatar
  end


  # -------------------------------------------------------------
  def is_enrolled?(course_offering)
    course_offering && course_offerings.include?(course_offering)
  end

  # -------------------------------------------------------------
  def manages?(course_offering)
    role_for_course_offering(course_offering).andand.can_manage_course?
  end


  # -------------------------------------------------------------
  def teaches?(course_offering)
    role_for_course_offering(course_offering).andand.is_instructor?
  end


  # -------------------------------------------------------------
  def grades?(course_offering)
    role_for_course_offering(course_offering).andand.can_grade_submissions?
  end


  # -------------------------------------------------------------
  def is_staff?(course_offering)
    role_for_course_offering(course_offering).andand.is_staff?
  end


  # -------------------------------------------------------------
  def role_for_course_offering(course_offering)
    course_offering && course_enrollments.
      where(course_offering: course_offering).first.andand.course_role
  end

  # -------------------------------------------------------------
  # Omni auth for Facebook and Google Users
  def self.from_omniauth(auth, guest = nil)
    user = nil
    identity = Identity.where(uid: auth.uid, provider: auth.provider).first
    if identity
      user = identity.user
    else
      if auth.provider == :cas
        auth.info.email = auth.uid + '@vt.edu'
      end
      if auth.info.email
        user = User.where(email: auth.info.email).first
        if !user
          user = User.create(
            first_name: auth.info.first_name,
            last_name: auth.info.last_name,
            email: auth.info.email,
            confirmed_at: DateTime.now,
            password: Devise.friendly_token[0, 20])
        end
      end
      if user
        user.identities.create(uid: auth.uid, provider: auth.provider)
      end
    end

    # Update any blank fields from provider's info, if available
    if user
      user.first_name ||= auth.info.first_name
      user.last_name ||= auth.info.last_name
      user.email ||= auth.info.email
      user.avatar ||= auth.info.image
      user.remember_created_at = DateTime.now
      if !user.confirmed_at
        user.confirmed_at = user.remember_created_at
      end
      if user.changed?
        user.save
      end
    end
    return user
  end


  # -------------------------------------------------------------
  def normalize_friendly_id(value)
    value.split('@').map{ |x| CGI.escape x }.join('@')
  end


  # -------------------------------------------------------------
  # Merge this user with the specifier user. The specified user's information
  # gets merged INTO this user
  def merge_with(user, email)
    return unless user.id != self.id
    # Update these attributes from merged user if they are currently blank
    [:encrypted_password, :first_name, :last_name, :avatar].each do |attr|
      new_value = user.read_attribute(attr)
      if self.read_attribute(attr).blank? && !new_value.blank?
        puts "update user #{self.id}: #{attr} <= #{new_value}"
        self[attr] = new_value
      end
    end
    [:current_workout_score_id, :time_zone_id].each do |attr|
      new_value = user.read_attribute(attr)
      if self.read_attribute(attr).nil? && !new_value.nil?
        puts "update user #{self.id}: #{attr} <= #{new_value}"
        self[attr] = new_value
      end
    end
    self.sign_in_count += user.sign_in_count
    puts "update user #{self.id}: sign_in_count <= #{self.sign_in_count}"
    if user.current_sign_in_at
      if !self.current_sign_in_at ||
        self.current_sign_in_at < user.current_sign_in_at
        puts "update user #{self.id}: " +
          "current_sign_in_at <= #{user.current_sign_in_at}"
        self.current_sign_in_at = user.current_sign_in_at
        puts "update user #{self.id}: " +
          "current_sign_in_ip <= #{user.current_sign_in_ip}"
        self.current_sign_in_ip = user.current_sign_in_ip
      end
    end
    if user.last_sign_in_at
      if !self.last_sign_in_at ||
        self.last_sign_in_at < user.last_sign_in_at
        puts "update user #{self.id}: " +
          "last_sign_in_at <= #{user.last_sign_in_at}"
        self.last_sign_in_at = user.last_sign_in_at
        puts "update user #{self.id}: " +
          "last_sign_in_ip <= #{user.last_sign_in_ip}"
        self.last_sign_in_ip = user.last_sign_in_ip
      end
    end
    if user.confirmed_at
      if !self.confirmed_at ||
        self.confirmed_at > user.confirmed_at
        puts "update user #{self.id}: " +
          "confirmed_at <= #{user.confirmed_at}"
        self.confirmed_at = user.confirmed_at
        puts "update user #{self.id}: " +
          "confirmation_token <= #{user.confirmation_token}"
        self.confirmation_token = user.confirmation_token
        puts "update user #{self.id}: " +
          "confirmation_sent_at <= #{user.confirmation_sent_at}"
        self.confirmation_sent_at = user.confirmation_sent_at
      end
    end
    if self.created_at > user.created_at
      puts "update user #{self.id}: " +
        "created_at <= #{user.created_at}"
      self.created_at = user.created_at
      puts "update user #{self.id}: " +
        "remember_created_at <= #{user.created_at}"
      self.remember_created_at = user.created_at
    end
    puts "update user #{user.id}: current_workout_score_id <= nil"
    user.current_workout_score = nil
    user.save!
    self.save!

    # Enrollments
    user.course_enrollments.each do |e|
      # only enroll this user if they are not already enrolled
      if !CourseEnrollment.find_by(
        course_offering: e.course_offering, user: self)
        puts "update course_enrollment #{e.id}: user_id <= #{self.id}"
        e.update(user_id: self.id)
      else
        puts "destroy course_enrollment #{e.id}"
        e.destroy
      end
    end
    user.course_enrollments.reset
    self.course_enrollments.reset

    # Extensions
    possible_ext_duplicates = {}
    user.student_extensions.each do |ext|
      self_extension = self.student_extensions.where(
        workout_offering: ext.workout_offering).limit(1).first
      if self_extension
        possible_ext_duplicates[ext.id] = self_extension.id
      end

      puts "update student_extenstion #{ext.id}: user_id <= #{self.id}"
      ext.update(user_id: self.id)
    end
    user.student_extensions.reset
    self.student_extensions.reset

    # Attempts
    puts "update user ids for #{user.attempts.count} attempts"
    user.attempts.update_all(user_id: self.id)
    user.attempts.reset
    self.attempts.reset

    # Test case results
    puts "update user ids for #{user.test_case_results.count} test_cast_results"
    user.test_case_results.update_all(user_id: self.id)
    user.test_case_results.reset
    self.test_case_results.reset

    # Workout Scores
    possible_ws_duplicates = {}
    user.workout_scores.each do |s|
      self_score = self.workout_scores.where(
        workout: s.workout,
        workout_offering: s.workout_offering).limit(1).first

      if self_score
        possible_ws_duplicates[s.id] = self_score.id
      end

      puts "update workout_score #{s.id}: user_id <= #{self.id}"
      s.update(user_id: self.id)
    end
    user.workout_scores.reset
    self.workout_scores.reset

    # LTI identities
    possible_lti_duplicates = {}
    user.lti_identities.each do |lti_id|
      existing_lti = LtiIdentity.find_by(
        lms_instance_id: lti_id.lms_instance, user: self)
      if existing_lti
        possible_lti_duplicates[existing_lti.id] = lti_id.id
      end
      puts "update lti_identities #{lti_id.id}: user_id <= #{self.id}"
      lti_id.update(user_id: self.id)
    end
    user.lti_identities.reset
    self.lti_identities.reset

    # devise identities
    puts "update user ids for #{user.identities.count} identities"
    user.identities.update_all(user_id: self.id)
    user.identities.reset
    self.identities.reset


    if !possible_ext_duplicates.empty? ||
      !possible_ws_duplicates.empty? ||
      !possible_lti_duplicates.empty?
      puts "-------------------------"
      puts "possible duplicates for: #{email}"
      possible_ext_duplicates.each do |k, v|
        puts "student_extensions,#{self.id},#{email},#{k}, #{v}"
      end
      possible_ws_duplicates.each do |k, v|
        puts "workout_scores,#{self.id},#{email},#{k}, #{v}"
      end
      possible_lti_duplicates.each do |k, v|
        puts "lti_identities,#{self.id},#{email},#{k}, #{v}"
      end
    end

    puts "destroy user #{user.id}"
    user.destroy
    puts "update user #{self.id}: email <= #{email}, slug <= #{user.slug}"
    self.update(email: email, slug: email)
    self.reload
  end


  # -------------------------------------------------------------
  # Merge this user with the specifier user. The specified user's information
  # gets merged INTO this user
  def check_merge_with(user, email)
    # Update these attributes from merged user if they are currently blank
    [:encrypted_password, :first_name, :last_name, :avatar].each do |attr|
      new_value = user.read_attribute(attr)
      if self.read_attribute(attr).blank? && !new_value.blank?
        # self.write_attribute(attr, new_value)
        puts "update user #{self.id}: #{attr} <= #{new_value}"
      end
    end
    [:current_workout_score_id, :time_zone_id].each do |attr|
      new_value = user.read_attribute(attr)
      if self.read_attribute(attr).nil? && !new_value.nil?
        # self.write_attribute(attr, new_value)
        puts "update user #{self.id}: #{attr} <= #{new_value}"
      end
    end
    # self.sign_in_count += user.sign_in_count
    puts "update user #{self.id}: " +
          "sign_in_count <= #{self.sign_in_count + user.sign_in_count}"
    if user.current_sign_in_at
      if !self.current_sign_in_at ||
        self.current_sign_in_at > user.current_sign_in_at
        # self.current_sign_in_at = user.current_sign_in_at
        puts "update user #{self.id}: " +
          "current_sign_in_at <= #{user.current_sign_in_at}"
        # self.current_sign_in_ip = user.current_sign_in_ip
        puts "update user #{self.id}: " +
          "current_sign_in_ip <= #{user.current_sign_in_ip}"
      end
    end
    if user.last_sign_in_at
      if !self.last_sign_in_at ||
        self.last_sign_in_at > user.last_sign_in_at
        # self.last_sign_in_at = user.last_sign_in_at
        puts "update user #{self.id}: " +
          "last_sign_in_at <= #{user.last_sign_in_at}"
        # self.last_sign_in_ip = user.last_sign_in_ip
        puts "update user #{self.id}: " +
          "last_sign_in_ip <= #{user.last_sign_in_ip}"
      end
    end
    if user.confirmed_at
      if !self.confirmed_at ||
        self.confirmed_at > user.confirmed_at
        # self.confirmed_at = user.confirmed_at
        puts "update user #{self.id}: " +
          "confirmed_at <= #{user.confirmed_at}"
        # self.confirmation_token = user.confirmation_token
        puts "update user #{self.id}: " +
          "confirmation_token <= #{user.confirmation_token}"
        # self.confirmation_sent_at = user.confirmation_sent_at
        puts "update user #{self.id}: " +
          "confirmation_sent_at <= #{user.confirmation_sent_at}"
      end
    end
    if self.created_at > user.created_at
      # self.created_at = user.created_at
      puts "update user #{self.id}: " +
        "created_at <= #{user.created_at}"
      # self.remember_created_at = user.created_at
      puts "update user #{self.id}: " +
        "remember_created_at <= #{user.created_at}"
    end
    puts "update user #{user.id}: current_workout_score_id <= nil"
    user.update(current_workout_score_id: nil)

    # Enrollments
    user.course_enrollments.each do |e|
      # only enroll this user if they are not already enrolled
      if !CourseEnrollment.find_by(
        course_offering: e.course_offering, user: self)
        # e.update(user_id: self.id)
        puts "update course_enrollment #{e.id}: user_id <= #{self.id}"
      else
        #e.destroy
        puts "destroy course_enrollment #{e.id}"
      end
    end

    # Extensions
    possible_ext_duplicates = {}
    user.student_extensions.each do |ext|
      self_extension = self.student_extensions.where(
        workout_offering: ext.workout_offering).limit(1).first
      if self_extension
        possible_ext_duplicates[ext.id] = self_extension.id
      end

      # ext.update(user_id: self.id)
      puts "update student_extenstion #{ext.id}: user_id <= #{self.id}"
    end

    # Attempts
    # user.attempts.update_all(user_id: self.id)
    user.attempts.each do |attempt|
      puts "update attempt #{attempt.id}: user_id <= #{self.id}"
    end

    # Test case results
    # user.test_case_results.update_all(user_id: self.id)
    user.test_case_results.each do |tcr|
      puts "update test_case_result #{tcr.id}: user_id <= #{self.id}"
    end

    # Workout Scores
    possible_ws_duplicates = {}
    user.workout_scores.each do |s|
      self_score = self.workout_scores.where(
        workout: s.workout,
        workout_offering: s.workout_offering).limit(1).first

      if self_score
        possible_ws_duplicates[s.id] = self_score.id
      end

      # s.update(user_id: self.id)
      puts "update workout_score #{s.id}: user_id <= #{self.id}"
    end

    # LTI identities
    possible_lti_duplicates = {}
    user.lti_identities.each do |lti_id|
      existing_lti = LtiIdentity.find_by(
        lms_instance_id: lti_id.lms_instance, user: self)
      if existing_lti
        possible_lti_duplicates[existing_lti.id] = lti_id.id
      end
      # lti_id.update(user_id: self.id)
      puts "update lti_identity #{lti_id.id}: user_id <= #{self.id}"
    end

    # devise identities
    # user.identities.update_all(user_id: self.id)
    user.identities.each do |i|
      puts "update identity #{i.id}: user_id <= #{self.id}"
    end


    if !possible_ext_duplicates.empty? ||
      !possible_ws_duplicates.empty? ||
      !possible_lti_duplicates.empty?
      puts "-------------------------"
      puts "possible duplicates for: #{email}"
      possible_ext_duplicates.each do |k, v|
        puts "student_extensions,#{self.id},#{email},#{k}, #{v}"
      end
      possible_ws_duplicates.each do |k, v|
        puts "workout_scores,#{self.id},#{email},#{k}, #{v}"
      end
      possible_lti_duplicates.each do |k, v|
        puts "lti_identities,#{self.id},#{email},#{k}, #{v}"
      end
    end

    # user.destroy
    puts "destroy user #{user.id}"
    # self.update(email: email, user.slug)
    puts "update user #{self.id}: email <= #{email}, slug <= #{email}"
  end


  # --------------------------------------------------------------
  # Move this user from one section to another
  # Will exit with no effect if
  # * user is not currently enrolled in `from`
  # * `from` and `to` are not 'sister course offerings'
  # Workout offerings will not be moved if a matching workout offering can't
  # be found in the `to` section
  def change_sections(from, to)
    if !self.is_enrolled?(from)
      logger.warn "#{self.email} is not enrolled in " +
        "#{from.display_name_with_term}. No changes."
      return
    end

    if (from.course_id != to.course_id) || (from.term_id != to.term_id)
      logger.error "#{from.display_name_with_term} and " +
        "#{to.display_name_with_term} are not sister course_offerings. " +
        "No changes."
      return
    end

    # Move enrollment if needed
    if !self.is_enrolled?(to)
      from_enrollment = CourseEnrollment.
        find_by(user: self, course_offering: from)
      CourseEnrollment.create(user: self,
        course_offering: to, course_role: from_enrollment.course_role)
    else
      logger.warn "#{self.email} is already enrolled in " +
        "#{to.display_name_with_term}."
    end

    # Move workout scores
    wos = from.workout_offerings
    self.workout_scores.joins(:workout_offering).where(workout_offering:
      { course_offering: from }).each do |workout_score|
      wo = workout_score.workout_offering
      sister_wo = to.workout_offerings.where(workout: wo.workout).first
      if sister_wo
        sister_ws = sister_wo.score_for(self)
        if sister_ws
          logger.error "Cannot migrate workout score #{workout_score} to " +
            "workout offering #{wo.id} for user #{self.id}, because of " +
            "duplicate workout score #{sister_ws}"
        else
          workout_score.update(workout_offering: sister_wo)
        end
      end
    end
    # Move extensions
    wos.each do |wo|
      sister_wo = to.workout_offerings.where(workout: wo.workout).first
      from_user_extensions = wo.student_extensions.where(user: self)
      to_user_extensions = sister_wo.student_extensions.where(user: self)
      if from_user_extensions.count > 0
        if from_user_extensions.count > 1
          logger.error "User #{self.id} has multiple extensions for workout " +
            "offering #{wo}"
        end
        if to_user_extensions.count > 0
          logger.error "User #{self.id} already has an extension for workout " +
            "offering #{sister_wo}. Not migrating existing extensions from " +
            "workout offering #{wo}."
        else
          from_user_extensions.each do |ue|
            ue.update(workout_offering_id: sister_wo)
          end
        end
      end
    end

    # Unenroll
    self.course_enrollments.where(course_offering: from).each do |enrollment|
      enrollment.destroy
    end
  end

  # -------------------------------------------------------------
  # Find or create a user based on information received in a launch
  # request.
  # Required params: lis_person_contact_email_primary (a valid email)
  # Optional params: lti_identity, custom_canvas_user_login_id, first_name, last_name
  def self.lti_new_or_existing_user(opts)
    lis_email = opts[:lis_person_contact_email_primary]
    lis_email_match = lis_email.andand.match(/[^@]+@([^@]+)/) # Devise.email_regexp, but capturing the domain

    unless lis_email_match
      raise ArgumentError.new(
        "Expected opts[:lis_person_contact_email_primary] to be "\
        "a valid email address. Got #{opts[:lis_person_contact_email_primary]}")
    end

    domain = lis_email_match.captures[0]
    canvas_login = opts[:custom_canvas_user_login_id]

    # Find by lti_identity
    user = opts[:lti_identity].andand.user

    # Or find user by LTI email (guaranteed to be present in LTI v1.x)
    if !user
      user = User.find_by(email: lis_email)
    end

    # patch for VT Canvas non-PID e-mails
    if user && canvas_login.andand.match(Devise.email_regexp).nil?
      email = "#{canvas_login}@#{domain}" # PID-like email
      if email != user.email
        to_merge = User.find_by(email: email)
        if to_merge
          to_merge.merge_with(user, email)
          to_merge.save!
          user = to_merge
        end
      end
    end
    return user unless user.nil?

    # Find user by LTI email (which is guaranteed to be present in LTI v1.x)
    user = User.find_by(email: lis_email)
    return user unless user.nil?

    # Find user by canvas login
    if canvas_login
      if canvas_login.match(Devise.email_regexp)
      # Is the canvas login email-like?
        user = User.find_by(email: canvas_login)
      else
        # Use the LTI email domain to build a valid email from the canvas login
        email = "#{canvas_login}@#{domain}"
        user = User.find_by(email: email)
      end
    end
    return user unless user.nil?

    # Haven't yet found a user
    user = User.new(
      email: lis_email,
      first_name: opts[:first_name],
      last_name: opts[:last_name]
    )
    user.skip_password_validation = true
    user.save!

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
      # only set when creating a new user through LTI
      return false if skip_password_validation

      (!password.blank? && !password_confirmation.blank?) || new_record?
    end


    # -------------------------------------------------------------
    def email_or_id
      email || id
    end


    # -------------------------------------------------------------
    def should_generate_new_friendly_id?
      slug.blank? || email_changed?
    end

end

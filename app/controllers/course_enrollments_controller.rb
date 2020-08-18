class CourseEnrollmentsController < ApplicationController

  def new
    parse_params

    respond_to do |format|
      format.js
    end
  end

  def destroy
    course_enrollment = CourseEnrollment.find params[:id]
    course_enrollment.destroy

    respond_to do |format|
      format.json { render json: params[:id] }
    end
  end

  def choose_roster
    parse_params

    respond_to do |format|
      format.js
    end
  end

  def roster_upload
    @course_offering = CourseOffering.find params[:course_offering]
    file = params[:rosterfile]
    has_headers = !!params[:has_headers] # "true" or "false"

    success = true
    created_count = 0
    enrolled_count = 0
    duplicated_count = 0

    CSV.parse(File.read(file.path), headers: has_headers) do |row|
      email = has_headers ? row['email'] : row[0]
      user = User.find_by(email: email)
      if !user
        user = User.new(email: email, global_role: GlobalRole.regular_user)
        user.first_name = has_headers ? row['first_name'] : row[1]
        user.last_name = has_headers ? row['last_name'] : row[2]
        user.skip_password_validation = true
        if user.save
          created_count = created_count + 1
        else
          Rails.logger.error "Unable to save new user #{user.inspect}"
        end
      end

      if !@course_offering.is_enrolled?(user)
        course_role_field = has_headers ? row['course_role'] : row[3]
        if course_role_field.downcase.include?('instructor')
          course_role = CourseRole.instructor
        else
          course_role = CourseRole.student
        end

        if user.id && CourseEnrollment.create(course_offering: @course_offering, user: user, course_role: course_role)
          enrolled_count = enrolled_count + 1
        end
      else
        duplicated_count = duplicated_count + 1
      end
    end

    message = %(
      <strong>Enrollments complete</strong><br/>
      #{created_count} new user accounts created<br/>
      #{enrolled_count} users enrolled<br/>
      #{duplicated_count} already-enrolled users ignored).html_safe
    flash[:success] = message
    redirect_to organization_course_path(
      id: @course_offering.course.slug,
      organization_id: @course_offering.course.organization.slug,
      term_id: @course_offering.term.slug
    ) and return
  end

  def enroll_users
    emails = params[:emails]
    @course_offering = CourseOffering.find params[:course_offering_id]
    if params[:course_role_id]
      @course_role = CourseRole.find params[:course_role_id]
    else
      @course_role = CourseRole.student
    end

    errors = []
    successes = 0
    any_enrolled = false 
    if @course_offering.can_enroll? || current_user.manages?(@course_offering)
      # The course offering is open for enrollment or the current user can override
      # the enrollment deadline
      emails.each do |email|
        user = User.find_by email: email
        if user
          if user.is_enrolled?(@course_offering) && !user.manages?(@course_offering)
            # User is already enrolled in the course offering, but they do not 
            # manage the course offering.
            errors.push("<li>Could not enroll #{email} because they are already enrolled in the course.</li>")
          else
            cs = CourseEnrollment.new(
              user: user,
              course_offering: @course_offering,
              course_role: @course_role
            )
            cs.save
            successes = successes + 1
          end
        else
          errors.push("<li>Did not find a user associated with the email #{email}.</li>")
        end
      end
    else
      errors.push("<li>The enrollment cutoff date for this course offering has already passed.</li>")
    end

    all = successes == emails.length
    any = successes > 0

    respond_to do |format|
      notice = all ? "All students successfully enrolled." : (
        any ? "There were errors while trying to enroll some students.<ul>#{errors.join('')}</ul>"
          : "No students enrolled. Ran into the following errors.<ul>#{errors.join('')}</ul>"
      ).html_safe
      format.html {
        redirect_to organization_course_path(
          @course_offering.course.organization,
          @course_offering.course,
          @course_offering.term),
          notice: notice
      }

      format.json { render json: { any: any, notice: notice } }
    end
  end

  private

  def parse_params
    @term = Term.find params[:term_id] if params[:term_id]
    @course = Course.find params[:course_id] if params[:course_id]
    @course_offerings = current_user.andand.course_offerings_for_term(@term, @course)
  end
end

class UserGroupMailer < ActionMailer::Base
  default from: "noreply@codeworkout.org"

  def review_access_request(user, group_access_request, course=nil)
    @user = user
    @group_access_request = group_access_request
    @course = course
    @requester = group_access_request.user
    @user_group = group_access_request.user_group

    if course
      subject = "#{@requester.display_name} requests access to #{course.number} materials."
    else
      subject = "#{@requester.display_name} requests access to the group #{@user_group.name}"
    end

    mail(to: user.email, subject: subject)
  end
end

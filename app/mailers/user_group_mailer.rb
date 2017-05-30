class UserGroupMailer < ActionMailer::Base
  default from: "noreply@codeworkout.org"

  def review_access_request(user, requester, user_group, course=nil)
    @user = user
    @requester = requester
    @user_group = user_group
    @course = course

    if course
      subject = "#{requester.display_name} requests access to #{course.number} materials."
    else
      subject = "#{requester.display_name} requests access to the group #{user_group.name}"
    end

    mail(to: user.email, subject: subject)
  end
end

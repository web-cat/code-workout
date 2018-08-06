require 'tzinfo'
module UserHelper

  # ----------------------------------------------------------
  # For a given user and an input time in UTC, returns a time
  # converted to user's preferred timezone (if it exists)

  def user_time(user, utc_time)
    if utc_time.nil?
      return ''
    end

    # Timezone in which datetime string is returned is either the
    # user's timezone or the East Coast time
    if user.andand.time_zone && utc_time
      time_zone = user.time_zone
    else
      time_zone = TimeZone.find_by(name: "America/New_York")
    end
    user_time_zone = TZInfo::Timezone.get(time_zone.name)
    user_time = user_time_zone.utc_to_local(utc_time)
    #return user_time.to_s.split(" ")[0] + " " + user_time.to_s.split(" ")[1]
  end

  # ----------------------------------------------------------
  # For a given user and his/her time local, returns a time
  # converted to UTC

  def user_utc_time(user, user_time)
    if utc_time.nil?
      return ''
    end
    
    # Timezone in which datetime is returned is either the
    # user's timezone or the East Coast time
    if user.andand.time_zone && utc_time
      time_zone = user.time_zone
    else
      time_zone = TimeZone.find_by(name: "America/New_York")
    end
    user_time_zone = TZInfo::Timezone.get(time_zone.name)
    utc_time = user_time_zone.local_to_utc(user_time)
    return utc_time
  end

end

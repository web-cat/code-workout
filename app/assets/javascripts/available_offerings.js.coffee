$('.workouts.find_offering').ready ->
  # clicked on an existing workout offering
  # enroll the user and redirect to the workout_offering practice page
  $('.workout-offering').on 'click', ->
    course_offering_id = $(this).data 'course-offering-id'
    practice_url = $(this).data 'practice-url'
    user_id = $(this).data 'user-id'
    enroll_url = '/course_offerings/' + course_offering_id + '/enroll'
    $.ajax
      url: enroll_url
      type: 'post'
      dataType: 'json'
      data: { iframe: true, user_id: user_id }
      success: (data)->
        document.location.href = practice_url

  # clicked on a course offering
  # enroll the user, create the workout_offering, and redirect to
  # the workout_offering practice page
  $('.course-offering').on 'click', ->
    course_offering_id = $(this).data 'course-offering-id'
    workout_name = $(this).data 'workout-name'
    user_id = $(this).data 'user-id'
    from_collection = $(this).data 'from-collection'
    enroll_url = "/course_offerings/#{course_offering_id}/enroll"
    $.ajax
      url: enroll_url
      type: 'post'
      dataType: 'json'
      data: { iframe: true, user_id: user_id }
      success: (data)->
        wo_data =
          course_offering_id: course_offering_id,
          workout_name: workout_name
          from_collection: from_collection
          lti_params:
            lms_assignment_id: window.codeworkout.lms_assignment_id
            lis_outcome_service_url: window.codeworkout.lis_outcome_service_url
            lis_result_sourcedid: window.codeworkout.lis_result_sourcedid

        create_workout_offering(wo_data)

create_workout_offering = (wo_data) ->
  $.ajax
    url: "/course_offerings/#{wo_data.course_offering_id}/add_workout/#{wo_data.workout_name}"
    type: 'post'
    dataType: 'json'
    data: wo_data
    success: (data)->
      document.location.href = data['practice_url']

$('.workouts.new_or_existing').ready ->
  head = $('#head')
  $('.search-results').on 'click', '.btn-clone', ->
    clone_confirm_msg = 'A clone of this workout will be created, which you can then offer in your course offerings. Is this okay?'
    if confirm(clone_confirm_msg)
      workout = $(this).data 'workout-id'
      course = $(head).data 'course'
      organization = $(head).data 'organization'
      term = $(head).data 'term'
      url = '/courses/' + organization + '/' + course + '/' + term + '/workouts/' + workout + '/clone'
      window.location.href = url

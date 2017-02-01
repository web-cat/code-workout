$('.workouts.new_or_existing').ready ->
  head = $('h2#head')
  $('.search-results').on 'click', '.btn-clone', ->
    if confirm('A clone of this workout will be created, which you can then offer in your course offerings. Is this okay?')
      workout = $(this).data 'workout-id'
      course = $(head).data 'course'
      organization = $(head).data 'organization'
      term = $(head).data 'term'
      url = '/courses/' + organization + '/' + course + '/' + term + '/workouts/' + workout + '/clone'
      window.location.href = url

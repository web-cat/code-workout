jQuery.fn.StudentSearch = (config) ->
  element = $(this)
  initialized = element.hasClass('initialized')
  if !initialized
    element.addClass('initialized')
  course_offering_display = config.course_offering_display
  course_offering_id = config.course_offering_id
  notin = config.notin || false

  searchable =
    course_offering:
      id: course_offering_id
      display: course_offering_display

    element: element

    search_students: (callback) ->
      terms = element.find('#terms').val()
      $.ajax
        url: "/course_offerings/#{course_offering_id}/search_students?notin=#{notin}"
        type: 'get'
        data: { terms: terms }
        cache: true
        dataType: 'script'
        success: (data) =>
          if callback
            callback()

    clear_student_search: ->
      element.find('.header').empty()
      element.find('.msg').empty()
      element.find('#students').empty()
      element.find('#terms').val('')

    init_event_handlers: ->
      that = this
      element.find('#btn-student-search').click ->
        that.search_students(null)

      element.find('#terms').keydown (e) ->
        if e.keyCode == 13
          that.search_students(null)

      element.find('#students').on 'click', 'a', ->
        student_id = $(this).data 'student-id'
        student_display = $(this).text()
        element.trigger
          type: 'studentSelect'
          id: student_id
          display: student_display

    init: ->
      this.clear_student_search()
      element.find('.header').append "Searching for students from <u>#{course_offering_display}</u>"
      if !initialized
        this.init_event_handlers()

  searchable.init()

  return searchable

// Append the course enrollments dialog to the page body.
$('body').append(
  '<%= escape_javascript(render partial: "course_enrollments/new_enrollment_modal", locals: { course_offerings: @course_offerings }) %>');

// Display the dialog.
$('#new-enrollment-modal').modal('show');

///////////////////////////////////////
///        Helper functions         ///
///////////////////////////////////////

const alertIncomplete = (element) => {
  element.addClass('shake');
  setTimeout(element.removeClass('shake'), 1000);
};

const alertInfo = (message) => {
  $('#notice').html(message);
  $('#notice').show();
};

const isValidEmail = (email) => {
  const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
};

const checkCompleteness = () => {
  const course_offering = $('#course-offering');
  const student = $('#student');
  const course_role = $('#course-role');

  let complete = true;
  const result = {};
  if (course_offering.val() === '') {
    complete = false;
    alertIncomplete(course_offering);
  } else {
    result['course_offering'] = course_offering.val();
    result['course_offering_display'] = course_offering.find(':selected').text();
  }

  if (student.val() === '') {
    complete = false;
    alertIncomplete(student);
  } else {
    const emails = student.val().split(/\s+/);
    emails.forEach((e) => {
      if (!isValidEmail(e)) {
        $('#student').after(`"${e}" is not a valid email address.`);
        alertIncomplete(student);
        complete = false;
      }
    });
    result['users'] = emails;
  }

  if (course_role.val() === '') {
    complete = false;
    alertIncomplete(course_role);
  } else {
    result['course_role'] = course_role.val();
  }

  result['complete'] = complete;
  return result;
};

const enableEmailTextarea = () => {
  course_offering_select = $('#course-offering');
  course_offering = course_offering_select.val();
  if (course_offering !== '') {
    course_offering_display = course_offering_select.children(':selected').text();
    $('#student').attr('disabled', false);
  }
};

///////////////////////////////////////
///        Event handlers           ///
///////////////////////////////////////
// attach event handlers for modal display
$('#new-enrollment-modal').on('hidden.bs.modal', () => {
  // remove modal from DOM when it is not required
  $('#new-enrollment-modal').remove();
});

$('#new-enrollment-modal').on('shown.bs.modal', enableEmailTextarea); 

// attach event handlers for course_enrollments
$('#course-offering').change(() => {
  enableEmailTextarea();
  $('#student').focus();
});

// handle submit
$('#btn-enroll').on('click', () => {
  form_result = checkCompleteness();
  if (form_result.complete) {
    $.ajax({
      url: `/course_offerings/${form_result.course_offering}/enroll_users`,
      data: { course_role_id: form_result.course_role, emails: form_result.users },
      type: 'post',
      dataType: 'json',
      success: (data) => {
        if (data['any'] === true) {
          // Request update if the roster changed at all.
          $('#tab_roster').trigger({
            type: 'requestUpdate'
          });
        }
        $('#new-enrollment-modal').modal('hide');
        alertInfo(data['notice']);
      }
    });
  }
});

$('.course_offerings.new, .course_offerings.edit').ready(() => {
  initDatepicker();

  $('#add-offering').click(() => {
    addCourseOfferingFields();
  });
});

function initDatepicker() {
  input = $('#cutoff_date').flatpickr({
    enableTime: false,
    altInput: true,
    altFormat: 'F j, Y',
    allowInput: true
  });
}

function addCourseOfferingFields() {
  $('#individual-fields').append($('#label-field').html());
}
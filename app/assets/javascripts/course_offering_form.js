$('.course_offerings.new, .course_offerings.edit').ready(() => {
  initDatepicker();
});

function initDatepicker() {
  input = $('#cutoff_date').flatpickr({
    enableTime: false,
    altInput: true,
    altFormat: 'F j, Y',
    allowInput: true
  });
}

(function($, window, document) {
  $(document).on('ready turbolinks:load', function() {
    setSlidable();

    $('.toggle-slider').on('click', function() {
      var toggler = $(this);
      var isOpen = toggler.attr('data-is-open');
      isOpen = typeof isOpen !== 'undefined' ?
        isOpen.toString() === 'true' :
        false;
      if (isOpen) {
        toggler.fadeOut('fast'); // fade out the button so it can re-appear
      }
      $('.sidebar').toggle('slide', {}, 300, function() {
        toggler.attr('data-is-open', !isOpen);
        toggler.fadeIn('fast');
      });
    });
  });

  $(window).on('resize', function() {
    setSlidable();
  });

  function setSlidable() {
    var width = $(window).width();
		var sidebar = $('.sidebar');
    var shouldBeSlidable = width < 995 && sidebar.length > 0;
    $('.sidebar').toggleClass('slider', shouldBeSlidable);
    $('.content').toggleClass('underlay', shouldBeSlidable);
    if (shouldBeSlidable) {
      $('.sidebar').css('display', 'none');
      $('.toggle-slider').css('display', 'inherit');
      $('.toggle-slider').attr('data-is-open', false);
    } else {
      $('.sidebar').css('display', 'inherit');
      $('.toggle-slider').css('display', 'none');
    }
  }
})(window.jQuery, window, window.document);

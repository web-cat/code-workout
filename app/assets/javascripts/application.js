// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require js-routes
//= require bootstrap-dropdown.js
//= require codemirror
//= require codemirror/modes/clike
//= require_tree .
//= require bootstrap-wysihtml5

// Add the route helpers directly into the window object for easy access.
$.extend(window, Routes);

//use wysihtml5 rich text editor
$(document).ready(function(){

    $('.richtexteditor').each(function(i, elem) {
      $(elem).wysihtml5({
      		"font-styles": false,
      		"emphasis": true,
      		"lists": true,
      		"link": false,
      		"html": true,
      		"image": false
      	});
    });
});

function progress(percent, $element) {
    var progressBarWidth = percent * $element.width() / 100;
    $element.find('div').animate({ width: progressBarWidth }, 200).html(percent + "%&nbsp;");
}
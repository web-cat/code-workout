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
//= require modernizr
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap-sprockets
//= require bootstrap-editable
//= require bootstrap-editable-rails
//= require js-routes
//= require codemirror
//= require codemirror/modes/clike
//= require codemirror/modes/yaml
//= require bootstrap-wysihtml5
//= require cocoon
//= require cm
//= require jquery-readyselector
//= require moment
//= require bootstrap-datetimepicker
//= require mustache.min
//= require student_search
//= require workout_form
//= require flatpickr

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

function percentBar(filled, capacity, id) {
  var myCanvas = document.getElementById(id);
  var back = myCanvas.getContext("2d");
  var text = myCanvas.getContext("2d");
  var textSize = 10;
  var w = myCanvas.width;
  var h = myCanvas.height;
  var fillW = filled*w;
  var capW = capacity*w;
  var per = parseInt(filled * 100);
  var gradient = back.createLinearGradient(100,100,0,100,100,50);
  gradient.addColorStop(0,"#3da2b4");
  gradient.addColorStop(1,"white");

  text.textBaseline="middle";
  text.fillText("Text is here to stay",0,myCanvas.height/2);

  back.fillStyle="#000000";
  back.fillRect(0,0,w,h);
  back.fillStyle="#276874";
  back.fillRect(0,0,capW,h);
  back.fillStyle=gradient;
  back.fillRect(0,0,fillW,h);

}
$.fn.editable.defaults.mode = 'inline';

$(document).ready(function() {
  $('.xeditable').editable();
});

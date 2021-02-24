$(document).ready(function() {
  $(".dropdown-submenu a.second").on("click", function(e) {
    $(this)
    .next("ul")
    .toggle()
    .removeClass("hidden")
    e.stopPropagation()
    e.preventDefault()
  });
});
// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function openCity(evt, cityName) {
  var i,
    tabcontent,
    tablinks;

  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
  document.getElementById(cityName).style.display = "block";
  evt.currentTarget.className += " active";
}

$(document).on('turbolinks:load', function() {
  // get current URL path and assign 'active' class based on first directory.
  var pathname = window.location.pathname;
  // console.log(pathname);
  // end_of_first_dir = pathname.indexOf("/", 1);
  // pathname = pathname.slice(0, end_of_first_dir);
  $('ul.nav.nav-pills > li.nav-item > a[href="' + pathname + '"]').addClass('active');
});

$(document).on('turbolinks:load', function() {
  // get current URL path and assign 'active' class based on first directory.
  var pathname = window.location.pathname;
  end_of_first_dir = pathname.indexOf("/", 1);
  pathname = pathname.slice(0, end_of_first_dir);
  $('ul.navbar-nav > li.nav-item > a[href^="' + pathname + '"]').parent().addClass('active');
});

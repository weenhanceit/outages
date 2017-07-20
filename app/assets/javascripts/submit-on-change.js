$(document).on('turbolinks:load', function(e) {
  $('form.js-submit-on-change').change(function(event) {
    console.log('form auto-submitting');
    $(this).submit();
  }).on("ajax:success", function(e) {
    // console.log('Success');
  }).on("ajax:error", function(e) {
    // console.log('Failure');
  });
});

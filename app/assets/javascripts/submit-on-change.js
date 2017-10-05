$(document).on('turbolinks:load', function(e) {
  $('form.js-submit-on-change').change(function(event) {
    // console.log('form auto-submitting');
    $(".spinner").show();
    $(this).submit();
  }).on("ajax:success", function(e) {
    // console.log('Success');
  }).on("ajax:error", function(e) {
    // console.log('Failure');
  }).on("ajax:complete", function(e) {
    // console.log('Complete');
    $(".spinner").hide();
  });
});

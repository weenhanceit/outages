$(document).on('turbolinks:load', function(e) {
  // The spinner potentially gives feedback to the user, but is being used
  // to synchronize test cases.
  $('form.js-submit-on-change').change(function(event) {
    // console.log('Form auto-submitting');
    $("body").prepend('<div class="spinner"></div>');
    // console.log('Spinner shown');
    $(this).submit();
  }).on("ajax:success", function(e) {
    // console.log('Success');
  }).on("ajax:error", function(e) {
    // console.log('Failure');
  }).on("ajax:complete", function(e) {
    // console.log('Complete');
    $(".spinner").remove();
  });
});

$(document).on('turbolinks:load', function() {
  current_user_tz = $('.js-user-time-zone-iana').text().trim();
  // console.log('User time zone: ' + current_user_tz);
  current_user_tz_rails = $('.js-user-time-zone-rails').text().trim();
  browser_tz = $().get_timezone();
  // console.log('Browser time zone: ' + browser_tz);

  if (browser_tz !== current_user_tz) {
    msg = 'You appear to be in ' +
      browser_tz +
      ' time zone, but your preference is set to ' +
      current_user_tz_rails +
      '. If you want to change to ' +
      browser_tz +
      ', go to the preferences page.';

    // alert(msg);
    $('.js-time-zone-warning').html(msg);
  }
});

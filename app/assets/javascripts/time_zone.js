function delete_cookie(name) {
  var d = new Date();
  d.setTime(d.getTime() - 1000);
  var expires = "expires="+ d.toUTCString();
  document.cookie = name + "=;" + expires + ";path=/";
}

function get_cookie(name) {
  cookies = document.cookie.split(';');
  for(i = 0; i < cookies.length; i++) {
    cookie = cookies[i].trim();
    if (cookie.indexOf(name + "=") === 0) {
      return cookie.substring(name.length + 1);
    }
  }
  return null;
}

function set_cookie(name, cvalue) {
  var d = new Date();
  d.setTime(d.getTime() + 24 * 60 * 60 * 1000);
  var expires = "expires="+ d.toUTCString();
  document.cookie = name + "=" + cvalue + ";" + expires + ";path=/";
}

$(document).on('turbolinks:load', function() {
  cookie = get_cookie('tz');
  if (cookie === null) {
    current_user_tz = $('.js-user-time-zone-iana').text().trim();
    // console.log('User time zone: ' + current_user_tz);
    current_user_tz_rails = $('.js-user-time-zone-rails').text().trim();
    browser_tz = $().get_timezone();
    // console.log('Browser time zone: ' + browser_tz);

    link_to_settings = '<a href="/user/edit">preferences page</a>';
    // FIXME: Better check of browser timezone, AKA the Havana problem
    // FIXME: Only show time zone messages when logged in
    if (current_user_tz === "") {
      msg = '<li>Using the ' +
        browser_tz +
        ' time zone. ' +
        'If you want to change your time zone, ' +
        'go to the ' +
        link_to_settings +
        '.</li>';
    } else if (browser_tz !== current_user_tz) {
      msg = '<li>You appear to be in ' +
        browser_tz +
        ' time zone, but your preference is set to ' +
        current_user_tz_rails +
        '. If you want to change to ' +
        browser_tz +
        ', go to the ' +
        link_to_settings +
        '.</li>';
    }

    if (typeof msg !== 'undefined') {
      // alert(msg);
      $('.js-time-zone-warning').append(msg);

      set_cookie('tz', browser_tz);
    }
  }
});

$(document).on('turbolinks:load', function() {
  // Remember that text fields don't get the change event until they
  // lose focus.
  // TODO: Need more than keyup. They could paste text in, for example.
  $('.js-filter').keyup(function(e) {
    var search_string_element = $(e.target);
    var search_string = $(e.target).val().trim();
    console.log('Search string: ' + search_string);

    // Not doing this yet.
    // TODO: Change test cases and do minimum length of search string.
    // if (search_string.length < 3) {
    //   console.log('Too short.');
    //   return;
    // }

    var regexp = new RegExp(search_string, "i");
    var target_selector_string = search_string_element.data('target');
    console.log('Target: ' + target_selector_string);

    $(target_selector_string + ' li').each(function(x, e) {
      console.log('Looking at ' + $(e).text().trim());
      if (regexp.test($(e).text())) {
        console.log('Showing it');
        $(e).removeClass('hidden');
      } else {
        console.log('Hiding it');
        $(e).addClass('hidden');
      }
    });
  });
});

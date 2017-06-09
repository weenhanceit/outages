$(document).on('turbolinks:load', function() {
  $('.js-assign').click(function(event) {
    console.log('assign clicked');
    event.preventDefault();
  });

  $('.js-remove').click(function(event) {
    console.log('remove clicked');
    event.preventDefault();
  });

  $('js-selectable').click(function(event) {
    console.log('selectable clicked');
    event.preventDefault();
    target = $(event.target);
    if (target.hasClass('js-selected')) {
      target.removeClass('js-selected');
    } else {
      target.addClass('js-selected');
    }
  });
});

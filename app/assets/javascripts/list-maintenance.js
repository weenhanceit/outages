// jQueryUI implementation for assigning CIs on the Outage#edit and #new pages
$(document).on('turbolinks:load', function() {
  // The classes js-assign and js-remove go on buttons that assign and remove
  // elements between a pair of lists. The list is current an HTML ul list,
  // but may have to change.
  // The assign button can have a data attribute called `target` that is a
  // css selector, and ideally is an ID. The selector selects the list that
  // represents the assigned items. If there is no data
  // attribute for `target`, the default is `#js-assigned`. Similarly,
  // there's a data attribute called `source`, where the items come from,
  // and that defaults to `#js-available`.
  // The remove button can have a data attribute called `target` that is a
  // css selector, and ideally is an ID. The selector selects the list that
  // represents the items available to be assigned. If there is no data
  // attribute for `target`, the default is `#js-available`. Similarly,
  // there's a data attribute called `source`, where the items come from,
  // and that defaults to `#js-available`.
  $.fn.extend({
    destroy_element_for_rails: function () {
      // console.log('Destroying this: ' + $(this).html());
      // console.log('destroy SIZE: ' + this.length);
      $('input[id$="_destroy"]', this).val('1');
    },
    move_to: function(selector) {
      selector.append($(this));
    },
    undestroy_element_for_rails: function () {
      // console.log('Undestroying this: ' + $(this).html());
      // console.log('undestroy SIZE: ' + this.length);
      $('input[id$="_destroy"]', this).val('0');
    }
  });

  // Modelled on: http://jqueryui.com/selectable/
  $(".js-selectable").selectable();
  // LCR on top of selectable

  // Common code for the two callbacks below.
  function item_selector_text(e) {
    return 'li:contains(' + $.trim($(e).text()) + ')';
  }

  function source_selector(element, dflt) {
    return (source = $(element).data('source')) === undefined ?
      $(dflt) :
      $(source);
  }
  function target_selector(element, dflt) {
    return (target = $(element).data('target')) === undefined ?
      $(dflt) :
      $(target);
  }

  //  The server is now sending all CIs (except self) for both available
  //  lists. The ones that shouldn't be there are hidden.
  //  On an assign for either parent or child, you have to hide the CI
  //  in the other (child or parent respectively) available list.
  //  On a remove for either parent or child, you have to show the CI
  //  in the other (child or parent respectively) available list.

  $('.js-assign').click(function(event) {
    event.preventDefault();
    source = source_selector(event.target, '#js-available');
    target = target_selector(event.target, '#js-assigned');
    elements = $('.ui-selected', source);
    // console.log('ELEMENTS: ' + elements.length);
    elements.move_to(target);
    elements.undestroy_element_for_rails();

    // Handle the dependent/pre-requisite case, where the available list for
    // both has to be updated.
    if ((other = $(event.target).data('other')) !== undefined) {
      elements.each(function(i, e) {
        // console.log('e.text(): ' + $(e).text());
        // console.log('FOUND: ' + $('li:contains(' + $.trim($(e).text()) + ')', $(other)).length);
        // console.log('FOUND: ' + "$('li:contains('" + $.trim($(e).text()) + "')', $(other))");
        $(item_selector_text(e), $(other)).addClass('hidden');
      });
    }
  });

  $('.js-remove').click(function(event) {
    event.preventDefault();
    source = source_selector(event.target, '#js-assigned');
    target = target_selector(event.target, '#js-available');
    elements = $('.ui-selected', source);
    // console.log('ELEMENTS: ' + elements.length);
    elements.move_to(target);
    elements.destroy_element_for_rails();

    // Handle the dependent/pre-requisite case, where the available list for
    // both has to be updated.
    if ((other = $(event.target).data('other')) !== undefined) {
      elements.each(function(i, e) {
        // console.log('e.text(): ' + $(e).text());
        // console.log('FOUND: ' + $('li:contains(' + $.trim($(e).text()) + ')', $(other)).length);
        // console.log('FOUND: ' + "$('li:contains('" + $.trim($(e).text()) + "')', $(other))");
        $(item_selector_text(e), $(other)).removeClass('hidden');
      });
    }
  });

  //  NOTE: If I ever do ajax version:
  //  For the CI page, the assign button fires a patch that creates
  //  a new CisCi, then retrieves the updated box contents for both
  //  available and the target.
  //  The remove button fires a patch that deletes the CisCi, then
  //  retrieves the updated box contents for the source, and both
  //  targets.
  //  Both of the above can result in multiple patches, when the user
  //  moves multiple items (ctrl or shift click).
  //  May need promises to do one get at the end after multiple deletes.
});

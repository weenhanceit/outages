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

  function assign(event) {
    event.preventDefault();
    source = source_selector(event.target, '#js-available');
    target = target_selector(event.target, '#js-assigned');
    elements = $('.ui-selected', source);
    // console.log('ELEMENTS: ' + elements.length);
    elements.move_to(target);
    elements.undestroy_element_for_rails();

    if ((other = $(event.target).data('other')) !== undefined) {
      elements.each(function(i, e) {
        // console.log('e.text(): ' + $(e).text());
        // console.log('FOUND: ' + $('li:contains(' + $.trim($(e).text()) + ')', $(other)).length);
        // console.log('FOUND: ' + "$('li:contains('" + $.trim($(e).text()) + "')', $(other))");
        $('li:contains(' + $.trim($(e).text()) + ')', $(other)).addClass('hidden');
      });
    }

    return elements;
  }
  $('.js-assign').click(function(event) {
    assign(event);
  });

  function remove(event) {
    event.preventDefault();
    source = source_selector(event.target, '#js-assigned');
    target = target_selector(event.target, '#js-available');
    elements = $('.ui-selected', source);
    // console.log('ELEMENTS: ' + elements.length);
    elements.move_to(target);
    elements.destroy_element_for_rails();
    return elements;
  }
  $('.js-remove').click(function(event) {
    remove(event);
  });

  //  The server is now sending all CIs (except self) for both available
  //  lists. The ones that shouldn't be there are hidden.
  //  On an assign for either parent or child, you have to hide the CI
  //  in the other (child or parent respectively) available list.
  //  On a remove for either parent or child, you have to show the CI
  //  in the other (child or parent respectively) available list.

  $('.js-dag-assign').click(function(event) {
    // console.log('DAG ASSIGN');
    elements = assign(event);
  });

  $('.js-dag-remove').click(function(event) {
    // console.log('DAG REMOVE');
    other = $(event.target).data('other');
    elements = remove(event);
    elements.each(function(i, e) {
      // console.log('e.text(): ' + $(e).text());
      // console.log('FOUND: ' + $('li:contains(' + $.trim($(e).text()) + ')', $(other)).length);
      // console.log('FOUND: ' + "$('li:contains('" + $.trim($(e).text()) + "')', $(other))");
      $('li:contains(' + $.trim($(e).text()) + ')', $(other)).removeClass('hidden');
    });
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

  // Modelled on: http://jqueryui.com/sortable/#connect-lists
  // These two may be incompatible
  $("#js-assigned, #js-available").sortable({
    connectWith: ".js-connected"
  });
  // // Modelled on: http://jqueryui.com/droppable/#photo-manager
  // // There's the assigned and the available
  // var $assigned = $( "#assigned" ),
  //   $available = $( "#available" );
  //
  // // Let the assigned items be draggable
  // $( "li", $assigned ).draggable({
  //   cancel: "a.ui-icon", // clicking an icon won't initiate dragging
  //   revert: "invalid", // when not dropped, the item will revert back to its initial position
  //   containment: "document",
  //   helper: "clone",
  //   cursor: "move"
  // });
  //
  // // Let the available be droppable, accepting the assigned items
  // $available.droppable({
  //   accept: "#assigned > li",
  //   classes: {
  //     "ui-droppable-active": "ui-state-highlight"
  //   },
  //   drop: function( event, ui ) {
  //     deleteImage( ui.draggable );
  //   }
  // });
  //
  // // Let the assigned be droppable as well, accepting items from the available
  // $assigned.droppable({
  //   accept: "#available li",
  //   classes: {
  //     "ui-droppable-active": "custom-state-active"
  //   },
  //   drop: function( event, ui ) {
  //     recycleImage( ui.draggable );
  //   }
  // });
  //
  // // Image deletion function
  // var recycle_icon = "<a href='link/to/recycle/script/when/we/have/js/off' title='Recycle this image' class='ui-icon ui-icon-refresh'>Recycle image</a>";
  // function deleteImage( $item ) {
  //   $item.fadeOut(function() {
  //     var $list = $( "ul", $available ).length ?
  //       $( "ul", $available ) :
  //       $( "<ul class='assigned ui-helper-reset'/>" ).appendTo( $available );
  //
  //     $item.find( "a.ui-icon-available" ).remove();
  //     $item.append( recycle_icon ).appendTo( $list ).fadeIn(function() {
  //       $item
  //         .animate({ width: "48px" })
  //         .find( "img" )
  //           .animate({ height: "36px" });
  //     });
  //   });
  // }
  //
  // // Image recycle function
  // var available_icon = "<a href='link/to/available/script/when/we/have/js/off' title='Delete this image' class='ui-icon ui-icon-available'>Delete image</a>";
  // function recycleImage( $item ) {
  //   $item.fadeOut(function() {
  //     $item
  //       .find( "a.ui-icon-refresh" )
  //         .remove()
  //       .end()
  //       .css( "width", "96px")
  //       .append( available_icon )
  //       .find( "img" )
  //         .css( "height", "72px" )
  //       .end()
  //       .appendTo( $assigned )
  //       .fadeIn();
  //   });
  // }
});

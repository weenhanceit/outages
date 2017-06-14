// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// jQueryUI implementation for assigning CIs on the Outage#edit and #new pages
$(document).on('turbolinks:load', function() {
  // To generalize:
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
  // TODO: figure out where to put these functions so they don't get
  // loaded all the time, but won't frustrate us when testing.
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
  $('.js-assign').click(function(event) {
    event.preventDefault();
    source = source_selector(event.target, '#js-available');
    target = target_selector(event.target, '#js-assigned');
    elements = $('.ui-selected', source);
    // console.log('ELEMENTS: ' + elements.length);
    elements.move_to(target);
    elements.undestroy_element_for_rails();
  });
  $('.js-remove').click(function(event) {
    event.preventDefault();
    source = source_selector(event.target, '#js-assigned');
    target = target_selector(event.target, '#js-available');
    elements = $('.ui-selected', source);
    // console.log('ELEMENTS: ' + elements.length);
    elements.move_to(target);
    elements.destroy_element_for_rails();
  });

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

function openCity(evt, cityName) {
  var i,
    tabcontent,
    tablinks;

  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
  document.getElementById(cityName).style.display = "block";
  evt.currentTarget.className += " active";
}

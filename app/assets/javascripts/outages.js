// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// jQueryUI implementation for assigning CIs on the outage#edit page
$(document).on('turbolinks:load', function() {
  // TODO: figure out where to put these functions so they don't get
  // loaded all the time, but won't frustrate us when testing.
  // Inspired by http://railscasts.com/episodes/196-nested-model-form-revised
  $.fn.extend({
    destroy_element_for_rails: function () {
      // console.log('Destroying this: ' + $(this).html());
      $('input[id$="_destroy"]', this).val('1');
      $(this).hide();
    },
    move_to_assigned: function() {
      // If the ci_id is in the assigned list, but the delete field is "1",
      // just un-delete it.
      // Otherwise, create a new row.
      existing = $('#js-assigned li[id$=' + $(this).data('ci-id') + ']');
      console.log('EXISTING: ' + existing);
    },
    move_to_available: function () {
      available_element = '<li class="ui-widget-content" data-name="' +
                            $(this).data('name') +
                            '" data-id="' +
                            $(this).data('ci_id') +
                            '">' +
                            $(this).data('name') +
                            '</li>';
      $('#js-available').append(available_element);
    }
  });

  // Modelled on: http://jqueryui.com/selectable/
  $(".js-selectable").selectable();
  // LCR on top of selectable
  // FIXME: The selectors have to look in their own list because
  // both lists can have selections.
  $('.js-assign').click(function() {
    event.preventDefault();
    $('.ui-selected').appendTo('#js-assigned');
  });
  $('.js-remove').click(function() {
    event.preventDefault();
    elements = $('.ui-selected');
    // elements.clone().appendTo('#js-available');
    elements.move_to_available();
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

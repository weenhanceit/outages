$(document).on('turbolinks:load', function() {
  // From: https://developer.mozilla.org/en-US/docs/Web/Events/dragstart
  // and modified
  var dragged;
  var saved_background = null;
  var depth = 0;

  function set_background(element) {
    // console.log('Should I set background on element: ' + element.tagName);
    if (depth++ === 0) {
      saved_background = element.style.backgroundColor;
      element.style.backgroundColor = "#f0f0f0";
      // console.log("Yes. I saved: " + saved_background);
    }
  }

  function restore_background(element) {
    // console.log("I'm going to restore background on element: " + element.tagName + " to " + saved_background);
    if (--depth === 0){
      element.style.backgroundColor = saved_background;
      saved_background = null;
    }
  }

  $(".js-draggable").attr("draggable", true);

  $(".js-draggable").on("dragstart", function(event) {
    // console.log("dragstart: " + this.tagName + " " + this.className);
    dragged = event.target;
    event.target.style.opacity = 0.5;
    depth = 0;
  });

  $(".js-droppable").on("drag", function(event) {
    // console.log("drag: " + this.tagName + " " + this.className);
  });

  $(".js-droppable").on("dragend", function(event) {
    // console.log("dragend: " + this.tagName + " " + this.className);
    event.target.style.opacity = "";
  });

  $(".js-droppable").on("dragover", function(event) {
    // console.log("dragover: " + this.tagName + " " + this.className);
    // console.log("preventing default");
    event.preventDefault();
  });

  $(".js-droppable").on("dragenter", function(event) {
    // console.log("dsragenter this: " + this.tagName + " " + this.className);
    // console.log("dragenter target: " + event.target.tagName + " " + event.target.className);
    // if (event.target === this) {
      set_background(this);
    // }
  });

  $(".js-droppable").on("dragleave", function(event) {
    // console.log("dragleave this: " + this.tagName + " " + this.className);
    // console.log("dragleave target: " + event.target.tagName + " " + event.target.className);
    // if (event.target === this) {
      restore_background(this);
    // }
  });

  $(".js-droppable").on("drop", function(event) {
    // console.log("drop: " + this.tagName + " " + this.className);
    // console.log("drop: " + event.target.tagName + " " + event.target.className);
    // console.log("preventing default");
    event.preventDefault();
    // if (event.target === this) {
      restore_background(this);
    // }
    if (dragged.parentNode !== this) {
      // console.log("moving element");
      dragged.parentNode.removeChild(dragged);
      this.appendChild(dragged);
    }
  });
});

// doc-ready.js
// This contains the javascript handling for DOM element click to go to a controller#action

//1) To have the controller action generate a modal popup from a dom element:
// - { data: {url: "/<pathToController>/<action>.js", toggle: 'modal', target: '#modal_popup'}
// - have a <action>.js.erb view that contains:
//   $('#modal_content').html("<%= escape_javascript(render('<name_of_view>._file') ) %>");
// - have a _<name_of_view>.haml file to populate the dialog box

//# Show the correct Grade Band selector
prepModal = function(that, ev) {
}

console.log("*** doc-ready loaded");

// $("document").on('ready', function(event, state) {
//   // close out dialog box in case it is open
//   console.log("show modal popup")
//   $('#modal_popup').show;
//   $(".spinner").hide();
// })

// show spinner on AJAX start
$(document).on('ajaxStart', function(event, state) {
  console.log("*** data-url on click called");
  $(".spinner").show()
})

// // show spinner on submit
// $(document).on('submit', function(event, state) {
//   $(".spinner").show()
// })

// hide spinner on AJAX stop
$(document).on('ajaxStop', function(event, state) {
  console.log("*** data-url on click called");
  $(".spinner").hide()
})

$("[data-url]").on('click', function (e, state) {
  console.log("*** data-url on click called");
  // stop further processing (don't follow link, ...)
  ev.preventDefault()
  // make an ajax call to the data-url
  data_url = $(that).data('url')
  $.ajax(data_url)
})

// $("[data-url]").css('cursor','pointer')
// $('.pointer-cursor').css('cursor','pointer')
// $('.arrow-cursor').css('cursor', 'default')

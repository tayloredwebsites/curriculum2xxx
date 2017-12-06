

$(function() {

  //###################################
  //# EVENT HANDLERS

  //# Toggle display of the Top Nav bar
  toggleTopNav = function(that, ev) {
    $('#topNav').toggle();
  }


  //###################################
  //# ADD EVENT BINDINGS

  $(".fa-bars").on('click', function(event, state) {
    toggleTopNav(this, event)
  })

});



$(function() {

  //###################################
  //# EVENT HANDLERS

  //# Toggle display of the Top Nav bar
  toggleTopNav = function(that, ev) {
    $('#topNav').toggle();
  }


  //# Show the correct Grade Band selector
  showCorrectGradeBand = function(that, ev) {
    sel = $('.subject-with-gb option:selected')
    text = sel.text()
    var upperGBs = ['Fiz', 'Hem']
    if (upperGBs.indexOf(text) < 0) {
      // not in upper grade bands only subjects
      $('#upper-gbs-select').hide()
      $('#all-gbs-select').show()
    } else {
      // in upper grade bands only subjects
      $('#all-gbs-select').hide()
      $('#upper-gbs-select').show()
    }
  }


  //###################################
  //# ADD EVENT BINDINGS

  $(".fa-bars").on('click', function(event, state) {
    toggleTopNav(this, event)
  })


  $(".subject-with-gb").on('change', function(event, state) {
    showCorrectGradeBand(this, event)
  })

});

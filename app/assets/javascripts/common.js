

$(function() {

  var saveUpperGbs;
  var saveAllGbs;

  //###################################
  //# EVENT HANDLERS

  //# Toggle display of the Top Nav bar
  toggleTopNav = function(that, ev) {
    $('#topNav').toggle();
  }


  //# Show the correct Grade Band selector
  showCorrectGradeBand = function(that, ev) {
    sel = $('.subject-with-gb option:selected');
    text = sel.text();
    var upperGBs = ['Fiz', 'Hem'];
    if($('#all-gbs-select').length > 0) {
      $('#all-gbs-select').hide();
      saveAllGbs = $('#all-gbs-select').detach();
    }
    if($('#upper-gbs-select').length > 0) {
      $('#upper-gbs-select').hide();
      saveUpperGbs = $('#upper-gbs-select').detach();
    }
    if (upperGBs.indexOf(text) < 0) {
      // not in upper grade bands only subjects
      saveAllGbs.appendTo('#gb-container');
      $('#all-gbs-select').show();
    } else {
      // in upper grade bands only subjects
      saveUpperGbs.appendTo('#gb-container');
      $('#upper-gbs-select').show();
    }
  }


  //###################################
  //# ADD EVENT BINDINGS

  $(".fa-bars").on('click', function(event, state) {
    toggleTopNav(this, event);
  })


  $(".subject-with-gb").on('change', function(event, state) {
    showCorrectGradeBand(this, event);
  })

});

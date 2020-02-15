

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
  //# ADD EVENT BINDINGS AND HANDLERS TOGETHER

  readyFontSizes = function() {
    $("#pageHeaderFontSize .smallest-text").on("click", function(event, state) {
      setSmallestText(this, event);
    })
    $("#pageHeaderFontSize .smaller-text").on("click", function(event, state) {
      setSmallerText(this, event);
    })
    $("#pageHeaderFontSize .medium-text").on("click", function(event, state) {
      setMediumText(this, event);
    })
    $("#pageHeaderFontSize .larger-text").on("click", function(event, state) {
      setLargerText(this, event);
    })
    $("#pageHeaderFontSize .largest-text").on("click", function(event, state) {
      setLargestText(this, event);
    })
  }


  setSmallestText = function(that, ev) {
    $("#outer-container").addClass("smallest-text");
    $("#outer-container").removeClass("smaller-text");
    $("#outer-container").removeClass("medium-text");
    $("#outer-container").removeClass("larger-text");
    $("#outer-container").removeClass("largest-text");
  }

  setSmallerText = function(that, ev) {
    $("#outer-container").removeClass("smallest-text");
    $("#outer-container").addClass("smaller-text");
    $("#outer-container").removeClass("medium-text");
    $("#outer-container").removeClass("larger-text");
    $("#outer-container").removeClass("largest-text");
  }

  setMediumText = function(that, ev) {
    $("#outer-container").removeClass("smallest-text");
    $("#outer-container").removeClass("smaller-text");
    $("#outer-container").addClass("medium-text");
    $("#outer-container").removeClass("larger-text");
    $("#outer-container").removeClass("largest-text");
  }

  setLargerText = function(that, ev) {
    $("#outer-container").removeClass("smallest-text");
    $("#outer-container").removeClass("smaller-text");
    $("#outer-container").removeClass("medium-text");
    $("#outer-container").addClass("larger-text");
    $("#outer-container").removeClass("largest-text");
  }

  setLargestText = function(that, ev) {
    $("#outer-container").removeClass("smallest-text");
    $("#outer-container").removeClass("smaller-text");
    $("#outer-container").removeClass("medium-text");
    $("#outer-container").removeClass("larger-text");
    $("#outer-container").addClass("largest-text");
  }


  selectCurriculum = function(refresh_path, user_id) {
    var selected = JSON.parse(document.getElementById("selectCurriculumDropdown").value);
    console.log("selected curriculum: " + selected);
    //[cur[:tree_type_id], cur[:version_id]
    var data = {
          "source_controller": "users",
          "source_action": "set_curriculum",
          "user[last_tree_type_id]" : selected[0],
          "user[last_version_id]" : selected[1],
          "user[user_id]" : user_id,
          "user[refresh_path]" : refresh_path,
        };
    var token = $("meta[name='csrf-token']").attr('content');
    $.ajax({
      "type": 'patch',
      "url": '/users/set_curriculum',
      "headers": { 'X-CSRF-Token': token },
      "data": data,
      "dataType": "json",
      "async": false
    })
    .then(function (res) {
      if (res.refresh) location.reload()
      else document.location.href="/";
    })
    .catch(function (err) { console.log("ERROR:", err) })
  }

  //###################################
  //# ADD EVENT BINDINGS

  $(document).on('turbolinks:load', function(event, state) {
    console.log('turbolinks:load');
    readyFontSizes();
  });
  readyFontSizes();

  $(".fa-bars").on('click', function(event, state) {
    toggleTopNav(this, event);
  })


  $(".subject-with-gb").on('change', function(event, state) {
    showCorrectGradeBand(this, event);
  })

});

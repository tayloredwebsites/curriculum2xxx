$(function() {
  var saveUpperGbs;
  var saveAllGbs;

  //###################################
  //# EVENT HANDLERS

  //# Toggle display of the Top Nav bar
  toggleTopNav = function(that, ev) {
    $("#topNav").toggle();
  };

  //# Show the correct Grade Band selector
  showCorrectGradeBand = function(that, ev) {
    sel = $(".subject-with-gb option:selected");
    text = sel.text();
    var upperGBs = ["Fiz", "Hem"];
    if ($("#all-gbs-select").length > 0) {
      $("#all-gbs-select").hide();
      saveAllGbs = $("#all-gbs-select").detach();
    }
    if ($("#upper-gbs-select").length > 0) {
      $("#upper-gbs-select").hide();
      saveUpperGbs = $("#upper-gbs-select").detach();
    }
    if (upperGBs.indexOf(text) < 0) {
      // not in upper grade bands only subjects
      saveAllGbs.appendTo("#gb-container");
      $("#all-gbs-select").show();
    } else {
      // in upper grade bands only subjects
      saveUpperGbs.appendTo("#gb-container");
      $("#upper-gbs-select").show();
    }
  };

  //###################################
  //# ADD EVENT BINDINGS AND HANDLERS TOGETHER

  readyFontSizes = function() {
    $("#pageHeaderFontSize .smallest-text").on("click", function(event, state) {
      setSmallestText(this, event);
    });
    $("#pageHeaderFontSize .smaller-text").on("click", function(event, state) {
      setSmallerText(this, event);
    });
    $("#pageHeaderFontSize .medium-text").on("click", function(event, state) {
      setMediumText(this, event);
    });
    $("#pageHeaderFontSize .larger-text").on("click", function(event, state) {
      setLargerText(this, event);
    });
    $("#pageHeaderFontSize .largest-text").on("click", function(event, state) {
      setLargestText(this, event);
    });
  };

  setSmallestText = function(that, ev) {
    $("#outer-container").addClass("smallest-text");
    $("#outer-container").removeClass("smaller-text");
    $("#outer-container").removeClass("medium-text");
    $("#outer-container").removeClass("larger-text");
    $("#outer-container").removeClass("largest-text");
  };

  setSmallerText = function(that, ev) {
    $("#outer-container").removeClass("smallest-text");
    $("#outer-container").addClass("smaller-text");
    $("#outer-container").removeClass("medium-text");
    $("#outer-container").removeClass("larger-text");
    $("#outer-container").removeClass("largest-text");
  };

  setMediumText = function(that, ev) {
    $("#outer-container").removeClass("smallest-text");
    $("#outer-container").removeClass("smaller-text");
    $("#outer-container").addClass("medium-text");
    $("#outer-container").removeClass("larger-text");
    $("#outer-container").removeClass("largest-text");
  };

  setLargerText = function(that, ev) {
    $("#outer-container").removeClass("smallest-text");
    $("#outer-container").removeClass("smaller-text");
    $("#outer-container").removeClass("medium-text");
    $("#outer-container").addClass("larger-text");
    $("#outer-container").removeClass("largest-text");
  };

  setLargestText = function(that, ev) {
    $("#outer-container").removeClass("smallest-text");
    $("#outer-container").removeClass("smaller-text");
    $("#outer-container").removeClass("medium-text");
    $("#outer-container").removeClass("larger-text");
    $("#outer-container").addClass("largest-text");
  };

  selectCurriculum = function(refresh_path, user_id) {
    var selected = JSON.parse(
      document.getElementById("selectCurriculumDropdown").value
    );
    console.log("selected curriculum: " + selected);
    //[cur[:tree_type_id], cur[:version_id]
    var data = {
      source_controller: "users",
      source_action: "set_curriculum",
      "user[last_tree_type_id]": selected[0],
      "user[last_version_id]": selected[1],
      "user[user_id]": user_id,
      "user[refresh_path]": refresh_path
    };
    var token = $("meta[name='csrf-token']").attr("content");
    $.ajax({
      type: "patch",
      url: "/users/set_curriculum",
      headers: { "X-CSRF-Token": token },
      data: data,
      dataType: "json",
      async: false
    })
      .then(function(res) {
        if (res.refresh) location.reload();
        else document.location.href = "/";
      })
      .catch(function(err) {
        console.log("ERROR:", err);
      });
  };


  show_hide_selection = function(selection, show) {
    if (show) {
      $(".top-selector" + " i.accordion").addClass("option-selected");
      $(".top-selector" + " i.accordion").removeClass("fa-expand");
      $(".top-selector" + " i.accordion").addClass("fa-compress");
      $(selection).removeClass("hidden");
      $(selection + " i.accordion").removeClass("fa-expand");
      $(selection + " i.accordion").addClass("fa-compress");
      $(selection + " i.accordion").addClass("option-selected");
    } else {
      $(".top-selector" + " i.accordion").removeClass("option-selected");
      $(".top-selector" + " i.accordion").removeClass("fa-compress");
      $(".top-selector" + " i.accordion").addClass("fa-expand");
      $(selection).addClass("hidden");
    }
    var showing_details = $("#show-details-btn #show-text").hasClass('hidden');
    if (showing_details) {
      $(".comp-col").addClass("col-lg-2 col-md-4 col-sm-11");
      $(".related-items-table .row").removeClass('hide-children');
    }
    else {
      $(".comp-col").removeClass("col-lg-2 col-md-4 col-sm-11");
      $(".related-items-table .row").addClass('hide-children');
    }
  };

  show_hierarchy_level = function (level, maxLevel) {
    $(".level-" + level).removeClass("hidden");
    var removeClass = (level == maxLevel ? "fa-expand" : "option-selected fa-compress");
    var addClass = (level == maxLevel ? "option-selected fa-compress" : "fa-expand")
    $(".level-" + level + " i.accordion").removeClass(removeClass);
    $(".level-" + level + " i.accordion").addClass(addClass);
    level = parseInt(level);
    for (var i = 0; i < level; i++ ) {
      $(".level-" + i).removeClass("hidden");
      $(".level-" + i + " i.accordion").removeClass(removeClass);
      $(".level-" + i + " i.accordion").addClass(addClass);
    }
    for (var i = level + 1; i <= maxLevel; i++ ) {
      $(".level-" + i).addClass("hidden");
    }
  }

  show_maint_details = function (show_details, resize) {
   // var showing_details = $("#show-details-btn #show-text").hasClass('hidden');
   // $("#show-details-btn #show-text").toggleClass('hidden');
   // $("#show-details-btn #hide-text").toggleClass('hidden');
    if (show_details) {
      $(".related-items-table .row").removeClass('hide-children');
      $(".comp-col").addClass("col-lg-2");
      if (resize) {
        $(".maint-column").removeClass("col-lg-7");
      }
    }
    else {
      $(".related-items-table .row").addClass('hide-children');
      $(".comp-col").removeClass("col-lg-2");
      if (resize) {
        $(".maint-column").addClass("col-lg-7");
      }
    }
  };

  init_hierarchy_show = function () {
    $(".btn-hierarchies").on("click", function () {
      show_hierarchy_level(
        $(this).data("hierarchy_depth"),
        $(this).data("outcome_depth"));
      show_maint_details(false, ($(this).data("resize")));
    });
    $("#show-details-btn").on("click", function() {
      show_hierarchy_level(
        $(this).data("hierarchy_depth"),
        $(this).data("outcome_depth"));
      show_maint_details(true, ($(this).data("resize")));
    })
  }

  init_admin_subjects_editing = function () {
    $('#admin-subjects-btn').on("click", function () {
      var subject = $('#admin-subjects-select').val();
      var admin_subjects = $('#user_admin_subjects').val();
       admin_subjects += (admin_subjects.length > 0 ? ',' + subject : subject);
      $('#user_admin_subjects').val(admin_subjects);
      var subject_tag = $( "<span id='admin-subject-"
        + subject + "' class='cloud-tag'>" + subject
        + "<button class='btn btn-small'> \
        <i class='fa fa-times'></i> \
        </button></span>" );
      $('#admin_subjects-selected').append(subject_tag);
    });

    $('.js-admin-subject-tag .btn').on("click", function () {
      var subject = $(this).attr('id').split("-")[2];
      var admin_subjects = $('#user_admin_subjects').val().split(',');
      admin_subjects = admin_subjects.filter(function (val) {
        return val != subject }).join(",");
      $('#user_admin_subjects').val(admin_subjects);
      $('#admin_subjects-selected').remove("#admin-subject-" + subject);
    });
  }
  //###################################
  //# ADD EVENT BINDINGS

  $(document).on("turbolinks:load", function(event, state) {
    console.log("turbolinks:load");
    $('[data-toggle="tooltip"]').tooltip({
      html: true,
      track: true
    });
    readyFontSizes();
    init_hierarchy_show();
    init_admin_subjects_editing();
  });
  readyFontSizes();
  init_hierarchy_show();
  init_admin_subjects_editing();

  $(".fa-bars").on("click", function(event, state) {
    toggleTopNav(this, event);
  });

  $(".subject-with-gb").on("change", function(event, state) {
    showCorrectGradeBand(this, event);
  });
  $('[data-toggle="tooltip"]').tooltip({
    html: true,
    track: true
  });

  /**
   * Allows focus to shift to the 'edit link' popup in the ckeditor
   * when the ckeditor itself is contained by a modal window.
   */
  $.fn.modal.Constructor.prototype._enforceFocus = function() {
  modal_this = this
  $(document).on('focusin.modal', function (e) {
    if (modal_this.$element) {
      if (modal_this.$element[0] !== e.target && !modal_this.$element.has(e.target).length
      && !$(e.target.parentNode).hasClass('cke_dialog_ui_input_select')
      && !$(e.target.parentNode).hasClass('cke_dialog_ui_input_text')) {
        modal_this.$element.focus()
      }
    }
  })
  };

});

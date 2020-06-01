//############################
//# Sequence Page Javascript #
//############################

$(function() {
  /**
   * Hide or show a subject column when the corresponding
   * checkbox is checked or unchecked.
   * @param  {String} subj_abbr Abbreviation for a subject.
   *                            E.g. 'bio', 'phy', etc.
   */
  subject_visibility = function(subj_abbr, max_subjs, err_translation) {
    err_translation =
      err_translation ||
      "Maximum number of subjects that can be displayed: " + max_subjs;
    var num_checked = $(".subj-checkbox>input:checked").length;
    if ($("#check-" + subj_abbr).prop("checked")) {
      if (num_checked <= max_subjs) {
        $("#" + subj_abbr + "-column").removeClass("hidden");
      } else {
        $("#check-" + subj_abbr).prop("checked", false);
        if (err_translation) alert(err_translation);
        return;
      }
    } else {
      $("#" + subj_abbr + "-column").addClass("hidden");
    }
    $(".sequence-grid").removeClass(
      "cols-0 cols-1 cols-2 cols-3 cols-4 cols-5 cols-6"
    );
    $(".sequence-page .sequence-grid").addClass(
      "cols-" + $(".subj-checkbox>input:checked").length
    );
  };

  /**
   * Hide or show LOs by subject and gradeband.
   * @param {Array<String>} subj_arr Array of abbreviations for a subject.
   *                            E.g. 'bio', 'phy', etc.
   * @param {String} gb_code The code for the affected gradeband.
   * @param {Boolean} multi True if multiple subjects are being
   *                        affected. This is needed because the
   *                        show/hide gradeband checkboxes for
   *                        "all subjects" should update the
   *                        single-subject checkboxes.
   */
  gradeband_visibility = function(subj_arr, gb_arr, multi) {
    var subj_abbr = subj_arr.pop();
    for (var gb in gb_arr) {
      var gb_code = gb_arr[gb];
      if (gb_arr.length > 1) {
        if ($("#all-gb-check-All").prop("checked")) {
          $("#" + subj_abbr + "-gb-check-" + gb_code).prop("checked", true);
          $("#all-gb-check-" + gb_code).prop("checked", true);
          $("#" + subj_abbr + "-column .lo_gb_code_" + gb_code).removeClass(
            "hidden"
          );
        } else {
          $("#" + subj_abbr + "-gb-check-" + gb_code).prop("checked", false);
          $("#all-gb-check-" + gb_code).prop("checked", false);
          $("#" + subj_abbr + "-column .lo_gb_code_" + gb_code).addClass(
            "hidden"
          );
        }
      } else {
        if (
          ($("#" + subj_abbr + "-gb-check-" + gb_code).prop("checked") &&
            !multi) ||
          ($("#all-gb-check-" + gb_code).prop("checked") && multi)
        ) {
          $("#" + subj_abbr + "-gb-check-" + gb_code).prop("checked", true);
          $("#" + subj_abbr + "-column .lo_gb_code_" + gb_code).removeClass(
            "hidden"
          );
        } else {
          $("#" + subj_abbr + "-gb-check-" + gb_code).prop("checked", false);
          $("#" + subj_abbr + "-column .lo_gb_code_" + gb_code).addClass(
            "hidden"
          );
        }
      }
    }
    if (subj_arr.length > 0) gradeband_visibility(subj_arr, gb_arr, multi);
  };

  /**
   * Generic toggle visibility method
   * @param {String} selector CSS selector for the element or elements to hide
   * @param {String} trigger CSS selector for the element triggering this function
   * @param {String} matchTrigger Selectors for elements or elements that should
   *                              be updated to match the trigger element's
   *                              settings with regard to the ".option-selected"
   *                              class.
   */
  toggle_visibility = function(selector, trigger, matchTrigger) {
    console.log(selector, trigger, matchTrigger);
    $(trigger).toggleClass("option-selected");
    var sel = $(trigger).hasClass("option-selected");
    if (sel) {
      $(selector).removeClass("hidden");
      if ($(trigger).hasClass("accordion")) {
        $(trigger).removeClass("fa-expand");
        $(trigger).addClass("fa-compress");
      }
      $(selector + " i.accordion").removeClass("fa-expand");
      $(selector + " i.accordion").addClass("fa-compress");
      $(selector + " i.accordion").addClass("option-selected");
    } else {
      $(selector).addClass("hidden");
      if ($(trigger).hasClass("accordion")) {
        $(trigger).removeClass("fa-compress");
        $(trigger).addClass("fa-expand");
      }
    }
    if (matchTrigger != undefined && matchTrigger != "") {
      $(matchTrigger).addClass(sel ? "option-selected" : "");
      $(matchTrigger).removeClass(!sel ? "option-selected" : "");
    }
  };

  /**
   * Expand and highlight related LOs
   */
  related_LO_display = function(rel, selected_LO) {
    if ($("#lo_" + selected_LO).hasClass("spotlight")) {
      $(".sequence-item--collapsable").removeClass(
        "collapsed spotlight spotlight-depends spotlight-akin spotlight-applies show-connections-condition"
      );
      for (var r in rel) {
        $("li[data-lo-id=" + rel[r][1] + "]")
          .find(".connections-icon")
          .attr("title", "show related LOs");
      }
    } else {
      $(".sequence-item--collapsable")
        .addClass("collapsed")
        .removeClass(
          "spotlight spotlight-depends spotlight-akin spotlight-applies show-connections-condition"
        );
      for (var r in rel) {
        console.log("spotlight ", rel[r][1]);
        $("#lo_" + rel[r][1])
          .removeClass("collapsed")
          .addClass("spotlight-" + rel[r][0] + " show-connections-condition");
      }
      $("#lo_" + selected_LO)
        .removeClass("collapsed")
        .addClass("spotlight show-connections-condition");
      $("#lo_" + selected_LO)
        .find(".connections-icon")
        .attr("title", "exit related LOs mode");
    }
  };

  showIndicators = function(show) {
    if (show) {
      $(".indicators-container").removeClass("hidden");
      $("#show-indicators").attr("hidden", true);
      $("#hide-indicators").attr("hidden", false);
    } else {
      $(".indicators-container").addClass("hidden");
      $("#show-indicators").attr("hidden", false);
      $("#hide-indicators").attr("hidden", true);
    }
  };
});

/**
 * Update an LO connection, and it's reciprocal connection
 * in one ajax call (also updates the translation of the
 * explanation for the current locale).
 * @param  {int} tree_tree_id The database ID of the
 *                            TreeTree/LO connection
 *                            being updated.
 */
patch_from_tree_tree_form = function(tree_tree_id) {
  explanation = $(
    'form#tree_tree_add_edit [name="tree_tree[explanation]"]'
  ).val();
  relationship = $("form#tree_tree_add_edit #relationship")
    .children("option:selected")
    .val();
  active = $('form#tree_tree_add_edit [name="tree_tree[active]"]').prop(
    "checked"
  );
  console.log("ACTIVE", active);

  data = {
    source_controller: "tree_trees",
    source_action: "update",
    "tree_tree[explanation]": explanation,
    "tree_tree[relationship]": relationship,
    "tree_tree[active]": active
  };
  ajax_update_tree_tree(tree_tree_id, data);
};

/**
 * Send a PATCH request to /tree_trees/:id with ajax
 * to activate or deactivate an LO connection, and
 * it's reciprocal (e.g., one request to deactivate
 * "bio.9.1.1.1 applies to che.9.1.3.3"
 * will also deactivate "che.9.1.3.3 depends on
 * bio.9.1.1.1.")
 * @param  {int} tree_tree_id The database ID of the
 *                            TreeTree/LO connection
 *                            being updated.
 * @param  {boolean} active   Should the TreeTree be
 *                            set to active with this
 *                            update?
 */
patch_tree_tree_activation = function(tree_tree_id, active) {
  data = {
    source_controller: "tree_trees",
    source_action: "update",
    "tree_tree[active]": active
  };
  ajax_update_tree_tree(tree_tree_id, data);
};

ajax_update_tree_tree = function(tree_tree_id, data) {
  token = $("meta[name='csrf-token']").attr("content");
  $.ajax({
    type: "patch",
    url: "/tree_trees/" + tree_tree_id,
    headers: { "X-CSRF-Token": token },
    data: data,
    dataType: "json",
    async: false
  })
    .then(function() {
      location.reload();
    })
    .catch(function(err) {
      console.log("ERROR:", err);
    });
};

/**
 * Build the add-edit form html for TreeTrees/LO connections,
 * to be embedded in a modal popup.
 * @param {object} res Ajax response object with translations
 *                     and data on the TreeTree being edited
 *                     or created.
 * @returns {string} html form for the add-edit popup.
 */
add_edit_form = function(res) {
  edit_mode = res.tree_tree.id != null;
  if (edit_mode) {
    submit_button =
      '<button class="btn btn-primary" type="button" \
        onclick="patch_from_tree_tree_form(' +
      res.tree_tree.id +
      ')">SAVE</button>';
  } else {
    submit_button = '<button class="btn btn-primary" type="submit">SAVE</button>';
  }
  return (
    '<div class="modal-header"> \
          <h3 id="myModalLabel"> LO ' +
    res.translations.relationship +
    '</h3> \
          </div> \
          <div class="modal-body"> \
          <form id="tree_tree_add_edit" action="/tree_trees"' +
    (edit_mode ? ">" : 'method="POST">') +
    '<div> \
          <input type="hidden" name="authenticity_token" value="' +
    $('[name="csrf-token"]').attr("content") +
    '"> \
          <input type="hidden" name="tree_tree[tree_referencer_id]" value=' +
    res.tree_tree.tree_referencer_id +
    '> \
          <input type="hidden" name="tree_tree[tree_referencee_id]" value=' +
    res.tree_tree.tree_referencee_id +
    '> \
    <input type="hidden" name="tree_tree[active]" value=' +
    true +
    '> \
          </div> \
          <fieldset> \
          <label for="relationship">' +
    res.translations.relationship +
    "</label><br>" +
    res.referencer_code +
    '<br> \
          <select id="relationship" name="tree_tree[relationship]"> \
          <option value="' +
    res.relation_values.akin +
    (res.tree_tree.relationship == "akin" ? '" selected>' : '">') +
    res.translations.akin +
    "</option> \
          <option value=" +
    res.relation_values.applies +
    (res.tree_tree.relationship == "applies" ? '" selected>' : '">') +
    res.translations.applies +
    '</option> \
          <option value="' +
    res.relation_values.depends +
    (res.tree_tree.relationship == "depends" ? '" selected>' : '">') +
    res.translations.depends +
    '</option> \
          </select> \
          <div>' +
    res.referencee_code +
    '</div><br> \
          </fieldset>' +
    submit_button +
    '<button type="button" class="btn" type="button" data-dismiss="modal" \
          aria-hidden="true">CANCEL</button> \
          </div> \
          </form>'
  );
};

edit_tree_tree = function(tree_tree_id) {
  $("#modal_popup").modal("show");
  $.ajax({
    type: "get",
    url: "/tree_trees/" + tree_tree_id + "/edit/",
    async: false
  })
    .then(function(res) {
      console.log("RESPONSE:", res.tree_tree.id);
      $("#modal-container").html(add_edit_form(res));
    })
    .catch(function(err) {
      console.log("ERROR:", err);
    });
};

initializeAddOutcome = function() {
  $(".createLO").on("click", function() {
    var outcome_depth = $(".btn-hierarchies").first().data("outcome_depth");
    show_hierarchy_level(outcome_depth, outcome_depth);
    var sort_order = $(this).data("nextsortorder");
    var subject_id = $(this).data("subjectid");
    var grade_band_id = $(this).data("gbid");
    var depth = $(this).data("childdepth");
    var parentElemId = $(this).parent().attr("id");
    var parentCode = $(this).data("parentCode");
    var token = $("meta[name='csrf-token']").attr("content");
    $.ajax({
      type: "get",
      url: "/trees/new",
      headers: { "X-CSRF-Token": token },
      data: {
        source_controller: "trees",
        source_action: "new",
        tree: {
          subject_id: subject_id,
          grade_band_id: grade_band_id,
          sort_order: sort_order,
          depth: depth,
          parent_code: parentCode,
          parent_elem_id: parentElemId
        }
      },
      dataType: "script",
      async: false
    })
    .catch(function(err) {
      window.location.reload();
      console.log("ERROR:", err);
    })
  })
}

/**
 *
 * 1) Initializes jqueryui sort behavior for LOs
 *    within a given subject, and across gradebands.
 * 2) Initializes jqueryui drag (and snap back into place)
 *    behavior for LOs within and across subjects and
 *    gradebands.
 */
initializeSortAndDrag = function() {
  $(".maint-page .list-group").sortable({
    //specify only .list-group-items
    //should be sortable (to
    //exclude subject headers)
    items: ".list-group-item",
    placeholder: "drop-placeholder",
    handle: ".sort-handle",
    stop: function(e, ui) {
      // console.log("e:", e);
      // console.log("ui:", ui);
      $(".spotlight-new").removeClass("spotlight-new");
      ui.item.addClass("spotlight-new");
      $(".sequence-item").removeClass("hidden");
      tree_ids = $(".sequence-item").map(function () {
        return $(this).data('treeid');
      }).get();
      console.log(tree_ids);
      token = $("meta[name='csrf-token']").attr("content");

      $.ajax({
        type: "post",
        url: "/trees/reorder",
        headers: { "X-CSRF-Token": token },
        data: {
          source_controller: "trees",
          source_action: "reorder",
          tree: { id_order: tree_ids }
        },
        dataType: "json",
        async: false
      })
        .then(function(res) {
          console.log(res.tree_codes_changed);
          var subject_code = $("#subject_code_hidden").text();
          res.tree_codes_changed.forEach(function (h) {
            $("#"+subject_code+"_tree_"+h["tree_id"])
              .find(".js-tree-code")
              .html(
                "<strong><em>"
                +h["new_code"]
                +"</em></strong>"
              )
          })
        })
        .catch(function(err) {
          window.location.reload();
          console.log("ERROR:", err);
      });
    }
  });

  $(".sequence-page .list-group-item").draggable({
    revert: true,
    zIndex: 101,
    cursorAt: {
      top: 60,
      left: 60
    },
    helper: "clone",
    handle: ".connect-handle",
    start: function(e, ui) {
      console.log(ui);
      $(ui.helper).addClass("ui-draggable-helper");
    },
    drag: function(e, ui) {
      //  var el_under_mouse = document.elementFromPoint(e.clientX, e.clientY);
      // //closest() returns null if no parent found with selector
      // el_under_mouse.closest('.list-group-item').className += 'highlight';
    },
    stop: function(e, ui) {
      console.log(ui);
      var el_under_mouse = document.elementFromPoint(e.clientX, e.clientY);
      //closest() returns null if no parent found with selector
      var lo_to_connect = el_under_mouse.closest(".list-group-item");
      if (lo_to_connect != null) {
        lo_to_connect = lo_to_connect.id.split("_")[1];
        lo_being_dragged = ui.helper[0].dataset["loId"];
        console.log(
          "under mouse",
          lo_to_connect,
          "original obj",
          lo_being_dragged
        );
        $("#modal_popup").modal("show");
        $.ajax({
          type: "get",
          url: "/tree_trees/new",
          data: {
            source_controller: "tree_trees",
            source_action: "new",
            "tree_tree[tree_referencer_id]": lo_being_dragged,
            "tree_tree[tree_referencee_id]": lo_to_connect
          },
          dataType: "json",
          async: false
        })
          .then(function(res) {
            console.log("RESPONSE:", res.tree_tree.id);
            $("#modal-container").html(add_edit_form(res));
          })
          .catch(function(err) {
            console.log("ERROR:", err);
          });
      }
    }
  });
};

$(document).on("turbolinks:load", function(event, state) {
  initializeSortAndDrag();
  initializeAddOutcome();
});
initializeSortAndDrag();
initializeAddOutcome();

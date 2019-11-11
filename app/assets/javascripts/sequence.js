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
  subject_visibility = function (subj_abbr) {
  	if ($('#check-' + subj_abbr).prop('checked')) {
  	   $('#'+subj_abbr+'-column').removeClass('hidden')
  	}
  	else {
  	   $('#'+subj_abbr+'-column').addClass('hidden')
  	}
  	$('.sequence-grid').removeClass('cols-0 cols-1 cols-2 cols-3 cols-4 cols-5 cols-6')
  	$('.sequence-page .sequence-grid').addClass('cols-' + $('.subj-checkbox input:checked').length )
  }

  /**
   * Expand and highlight related LOs
   */
  related_LO_display = function (rel, selected_LO) {
    if ($("#lo_" + selected_LO).hasClass('spotlight')) {
	  	$('.sequence-item--collapsable')
	  	  .removeClass('collapsed spotlight spotlight-depends spotlight-akin spotlight-applies show-connections-condition');
	  	for (var r in rel) {
	  		$('li[data-lo-id='+rel[r][1]+']')
	  		 .find('.connections-icon')
	  		 .attr('title', 'show related LOs');
	  	}
    }
    else {
      $('.sequence-item--collapsable')
  	  .addClass('collapsed')
  	  .removeClass('spotlight spotlight-depends spotlight-akin spotlight-applies show-connections-condition');
	  	for (var r in rel) {
	  	  console.log('spotlight ', rel[r][1])
	  	  $("#lo_" + rel[r][1])
	  		.removeClass('collapsed')
	  		.addClass('spotlight-' + rel[r][0] + ' show-connections-condition');
	  	}
      $("#lo_" + selected_LO)
        .removeClass('collapsed')
        .addClass('spotlight show-connections-condition');
      $("#lo_" + selected_LO)
         .find('.connections-icon')
         .attr('title', 'exit related LOs mode');
    }

  }

  showIndicators = function (show) {
    if (show) {
      $(".indicators-container").removeClass("hidden")
      $("#show-indicators").attr("hidden", true)
      $("#hide-indicators").attr("hidden", false)
    }
    else {
      $(".indicators-container").addClass("hidden")
      $("#show-indicators").attr("hidden", false)
      $("#hide-indicators").attr("hidden", true)
    }
  }

});

/**
 * Update an LO connection, and it's reciprocal connection
 * in one ajax call (also updates the translation of the
 * explanation for the current locale).
 * @param  {int} tree_tree_id The database ID of the
 *                            TreeTree/LO connection
 *                            being updated.
 */
patch_from_tree_tree_form = function (tree_tree_id) {
  explanation = $('form#tree_tree_add_edit [name="tree_tree[explanation]"]').val();
  relationship = $('form#tree_tree_add_edit #relationship').children("option:selected").val();
  active = $('form#tree_tree_add_edit [name="tree_tree[active]"]').prop("checked");
  console.log("ACTIVE", active);

  data = {
          "source_controller": "tree_trees",
          "source_action": "update",
          "tree_tree[explanation]" : explanation,
          "tree_tree[relationship]" : relationship,
          "tree_tree[active]" : active
        };
  ajax_update_tree_tree(tree_tree_id, data);
}

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
patch_tree_tree_activation = function (tree_tree_id, active) {
  data = {
          "source_controller": "tree_trees",
          "source_action": "update",
          "tree_tree[active]" : active
        };
  ajax_update_tree_tree(tree_tree_id, data)
}

ajax_update_tree_tree = function (tree_tree_id, data) {
  token = $("meta[name='csrf-token']").attr('content');
  $.ajax({
      "type": 'patch',
      "url": '/tree_trees/' + tree_tree_id,
      "headers": { 'X-CSRF-Token': token },
      "data": data,
      "dataType": "json",
      "async": false
    })
    .then(function () { location.reload() })
    .catch(function (err) { console.log("ERROR:", err) })
}

/**
 * Build the add-edit form html for TreeTrees/LO connections,
 * to be embedded in a modal popup.
 * @param {object} res Ajax response object with translations
 *                     and data on the TreeTree being edited
 *                     or created.
 * @returns {string} html form for the add-edit popup.
 */
add_edit_form = function (res) {
  edit_mode = res.tree_tree.id != null
  if (edit_mode) {
    submit_button = '<button type="button" \
        onclick="patch_from_tree_tree_form('
        + res.tree_tree.id
        +')">SAVE</button>'
  }
  else {
    submit_button = '<button type="submit">SAVE</button>'
  }
  return '<div class="modal-header"> \
          <h3 id="myModalLabel"> LO '+  res.translations.relationship +'</h3> \
          </div> \
          <div class="modal-body"> \
          <form id="tree_tree_add_edit" action="/tree_trees"' + (edit_mode ? '>' : 'method="POST">')
          + '<div> \
          <input type="hidden" name="authenticity_token" value="' + $('[name="csrf-token"]').attr('content') + '"> \
          <input type="hidden" name="tree_tree[tree_referencer_id]" value=' + res.tree_tree.tree_referencer_id +'> \
          <input type="hidden" name="tree_tree[tree_referencee_id]" value=' + res.tree_tree.tree_referencee_id + '> \
          </div> \
          <fieldset> \
          <label for="relationship">' + res.translations.relationship + '</label><br>'
          + res.referencer_code + '<br> \
          <select id="relationship" name="tree_tree[relationship]"> \
          <option value="' + res.relation_values.applies
          + (res.tree_tree.relationship == 'applies' ? '" selected>': '">')
          + res.translations.applies
          + '</option> \
          <option value="' + res.relation_values.depends
          + (res.tree_tree.relationship == 'depends' ? '" selected>': '">')
          + res.translations.depends
          + '</option> \
          <option value="' + res.relation_values.akin
          + (res.tree_tree.relationship == 'akin' ? '" selected>': '">')
          + res.translations.akin
          + '</option> \
          </select> \
          <div>' + res.referencee_code + '</div><br> \
          </fieldset> \
          <fieldset> \
            <label for="explanation">' + res.translations.explanation_label + '<br> \
            <textarea type="text" name="tree_tree[explanation]">'
            + (res.translations.explanation != undefined ? res.translations.explanation : '')
            +'</textarea> \
          </fieldset> \
          <fieldset><label for="tree_tree[active]">Active?</label>\
          <input name="tree_tree[active]" type="checkbox"'
          + (res.tree_tree.active ? ' checked' : '') + '></input></fieldset>'
          + submit_button
          + '<button type="button" type="button" data-dismiss="modal" \
          aria-hidden="true">CANCEL</button> \
          </div> \
          </form>'
}

edit_tree_tree = function (tree_tree_id) {
  $("#modal_popup").modal('show');
        $.ajax({
          "type": 'get',
          "url": '/tree_trees/'+ tree_tree_id + '/edit/',
          "async": false
        })
        .then(function (res) {
          console.log("RESPONSE:", res.tree_tree.id)
          $("#modal-container").html(add_edit_form(res))
        })
        .catch(function (err) { console.log("ERROR:", err) })
}

/**
 *
 * 1) Initializes jqueryui sort behavior for LOs
 *    within a given subject, and across gradebands.
 * 2) Initializes jqueryui drag (and snap back into place)
 *    behavior for LOs within and across subjects and
 *    gradebands.
 */
initializeSortAndDrag = function () {
   $('.sequence-page .list-group').sortable({
    //specify only .list-group-items
    //should be sortable (to
    //exclude subject headers)
    items: '.list-group-item',
    placeholder: 'drop-placeholder',
    handle: '.sort-handle',
    stop: function (e, ui) {
      console.log('e:', e)
      console.log('ui:', ui)
      tree_ids = $.map($(this).find('.sequence-item'), function(el) {
                 return el.id.split('_')[1]
              });
      console.log(tree_ids);
      token = $("meta[name='csrf-token']").attr('content');

      $.ajax({
        "type": 'post',
        "url": '/trees/reorder',
        "headers": { 'X-CSRF-Token': token },
        "data": {
          "source_controller": 'trees',
          "source_action": 'reorder',
          "id_order": tree_ids
        },
        "dataType": 'json',
        "async": false
      })
      .catch(function (err) { console.log("ERROR:", err) })
    }
    })

   $('.sequence-page .list-group-item').draggable({
     revert: true,
     zIndex: 100,
     cursorAt: {
            top: 60,
            left: 60
          },
     helper: 'clone',
     handle: '.connect-handle',
     start: function (e, ui) {
        console.log(ui)
        $(ui.helper).addClass("ui-draggable-helper");
     },
     drag: function (e, ui) {
      //  var el_under_mouse = document.elementFromPoint(e.clientX, e.clientY);
      // //closest() returns null if no parent found with selector
      // el_under_mouse.closest('.list-group-item').className += 'highlight';
     },
     stop: function (e,ui) {
      console.log(ui)
      var el_under_mouse = document.elementFromPoint(e.clientX, e.clientY);
      //closest() returns null if no parent found with selector
      var lo_to_connect = el_under_mouse.closest('.list-group-item')
      if (lo_to_connect != null) {
        lo_to_connect = lo_to_connect.id.split('_')[1];
        lo_being_dragged = ui.helper[0].dataset['loId']
        console.log('under mouse', lo_to_connect, 'original obj',  lo_being_dragged);
        $("#modal_popup").modal('show');
        $.ajax({
          "type": 'get',
          "url": '/tree_trees/new',
          "data": {
            "source_controller": 'tree_trees',
            "source_action": 'new',
            "tree_tree[tree_referencer_id]": lo_being_dragged,
            "tree_tree[tree_referencee_id]": lo_to_connect
          },
          "dataType": 'json',
          "async": false
        })
        .then(function (res) {
          console.log("RESPONSE:", res.tree_tree.id)
          $("#modal-container").html(add_edit_form(res))
        })
        .catch(function (err) { console.log("ERROR:", err) })

      }
     }
   })
}



$(document).on('turbolinks:load', function(event, state) {
 initializeSortAndDrag();
})
initializeSortAndDrag();
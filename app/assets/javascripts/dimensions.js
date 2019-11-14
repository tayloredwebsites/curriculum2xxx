//############################
//# Dimensions Page Javascript #
//############################


$(function() {
  /**
   * Show a subject's dimension and lo column when the corresponding
   * radio button is checked.
   * @param  {String} subj_abbr Abbreviation for a subject.
   *                            E.g. 'bio', 'phy', etc.
   */
    show_subject_dimensions = function (subj_abbr) {
    $('.subject-column').addClass('hidden')
  	$('#'+subj_abbr+'-dim-column').removeClass('hidden')
    $('#'+subj_abbr+'-lo-column').removeClass('hidden')
    }

  // /**
  //  * Expand and highlight related LOs
  //  */
  // related_LO_display = function (rel, selected_LO) {
  //   if ($("#lo_" + selected_LO).hasClass('spotlight')) {
	 //  	$('.sequence-item--collapsable')
	 //  	  .removeClass('collapsed spotlight spotlight-depends spotlight-akin spotlight-applies show-connections-condition');
	 //  	for (var r in rel) {
	 //  		$('li[data-lo-id='+rel[r][1]+']')
	 //  		 .find('.connections-icon')
	 //  		 .attr('title', 'show related LOs');
	 //  	}
  //   }
  //   else {
  //     $('.sequence-item--collapsable')
  // 	  .addClass('collapsed')
  // 	  .removeClass('spotlight spotlight-depends spotlight-akin spotlight-applies show-connections-condition');
	 //  	for (var r in rel) {
	 //  	  console.log('spotlight ', rel[r][1])
	 //  	  $("#lo_" + rel[r][1])
	 //  		.removeClass('collapsed')
	 //  		.addClass('spotlight-' + rel[r][0] + ' show-connections-condition');
	 //  	}
  //     $("#lo_" + selected_LO)
  //       .removeClass('collapsed')
  //       .addClass('spotlight show-connections-condition');
  //     $("#lo_" + selected_LO)
  //        .find('.connections-icon')
  //        .attr('title', 'exit related LOs mode');
  //   }

  // }

  // showIndicators = function (show) {
  //   if (show) {
  //     $(".indicators-container").removeClass("hidden")
  //     $("#show-indicators").attr("hidden", true)
  //     $("#hide-indicators").attr("hidden", false)
  //   }
  //   else {
  //     $(".indicators-container").addClass("hidden")
  //     $("#show-indicators").attr("hidden", false)
  //     $("#hide-indicators").attr("hidden", true)
  //   }
  // }

});

/**
 * Update an LO connection, and it's reciprocal connection
 * in one ajax call (also updates the translation of the
 * explanation for the current locale).
 * @param  {int} tree_tree_id The database ID of the
 *                            TreeTree/LO connection
 *                            being updated.
 */
// patch_from_tree_tree_form = function (tree_tree_id) {
//   explanation = $('form#tree_tree_add_edit [name="tree_tree[explanation]"]').val();
//   relationship = $('form#tree_tree_add_edit #relationship').children("option:selected").val();
//   active = $('form#tree_tree_add_edit [name="tree_tree[active]"]').prop("checked");
//   console.log("ACTIVE", active);

//   data = {
//           "source_controller": "tree_trees",
//           "source_action": "update",
//           "tree_tree[explanation]" : explanation,
//           "tree_tree[relationship]" : relationship,
//           "tree_tree[active]" : active
//         };
//   ajax_update_tree_tree(tree_tree_id, data);
// }

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
// patch_tree_tree_activation = function (tree_tree_id, active) {
//   data = {
//           "source_controller": "tree_trees",
//           "source_action": "update",
//           "tree_tree[active]" : active
//         };
//   ajax_update_tree_tree(tree_tree_id, data)
// }

// ajax_update_tree_tree = function (tree_tree_id, data) {
//   token = $("meta[name='csrf-token']").attr('content');
//   $.ajax({
//       "type": 'patch',
//       "url": '/tree_trees/' + tree_tree_id,
//       "headers": { 'X-CSRF-Token': token },
//       "data": data,
//       "dataType": "json",
//       "async": false
//     })
//     .then(function () { location.reload() })
//     .catch(function (err) { console.log("ERROR:", err) })
// }

/**
 * Build the add-edit form html for TreeTrees/LO connections,
 * to be embedded in a modal popup.
 * @param {object} res Ajax response object with translations
 *                     and data on the TreeTree being edited
 *                     or created.
 * @returns {string} html form for the add-edit popup.
 */
add_edit_dimtree_form = function (res) {
  edit_mode = res.dimension_tree.id != null
  if (edit_mode) {
    // submit_button = '<button type="button" \
    //     onclick="patch_from_dimension_tree_form('
    //     + res.dimension_tree.id
    //     +')">SAVE</button>'
  }
  else {
    // submit_button = '<button type="submit">SAVE</button>'
  }
  submit_button = '<button type="button" data-dismiss="modal" \
          aria-hidden="true">SAVE</button>'

  return '<div class="modal-header"> \
          <h3 id="myModalLabel">Connect LO with '+ res.dim_type +'</h3> \
          </div> \
          <div class="modal-body"> \
          <form id="tree_tree_add_edit" action="/tree_trees"' + (edit_mode ? '>' : 'method="POST">')
          + '<div> \
          <input type="hidden" name="authenticity_token" value="' + $('[name="csrf-token"]').attr('content') + '"> \
          <input type="hidden" name="tree[tree_id]" value=' + res.dimension_tree.tree_id +'> \
          <input type="hidden" name="tree[dimension_id]" value=' + res.dimension_tree.dimension_id + '> \
          </div> \
          <fieldset> \
          <div>' + res.tree_code + '</div>\
          <div>relates to</div> \
          <div>' + res.dimension_name + '</div><br> \
          </fieldset> \
          <fieldset> \
            <label for="explanation">' + res.translations.explanation_label + '<br> \
            <textarea type="text" name="tree_tree[explanation]">'
            + (res.translations.explanation != undefined ? res.translations.explanation : '')
            +'</textarea> \
          </fieldset>'
          + submit_button
          + '<button type="button" type="button" data-dismiss="modal" \
          aria-hidden="true">CANCEL</button> \
          </div> \
          </form>'
}

// edit_tree_tree = function (tree_tree_id) {
//   $("#modal_popup").modal('show');
//         $.ajax({
//           "type": 'get',
//           "url": '/tree_trees/'+ tree_tree_id + '/edit/',
//           "async": false
//         })
//         .then(function (res) {
//           console.log("RESPONSE:", res.tree_tree.id)
//           $("#modal-container").html(add_edit_form(res))
//         })
//         .catch(function (err) { console.log("ERROR:", err) })
// }

initializeDrag = function () {
   $('.dimension-page .list-group-item').draggable({
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
      var item_to_connect = el_under_mouse.closest('.list-group-item')
      if (item_to_connect != null) {
        var tree_id, dimension_id
        if (ui.helper[0].dataset['loid']) {
        	tree_id = ui.helper[0].dataset['loid']
          dimension_id = item_to_connect.id.split('_')[1]
        }
        else {
          tree_id = item_to_connect.id.split('_')[1]
          dimension_id = ui.helper[0].dataset['dimid']
        }
        console.log('treeeID', tree_id, "dimension_id", dimension_id)
       // $("#modal_popup").modal('show');
        $.ajax({
          "type": 'get',
          "url": '/trees/edit_dimensions',
          "data": {
            "source_controller": 'trees',
            "source_action": 'edit_dimensions',
            "tree[tree_id]": tree_id,
            "tree[dimension_id]": dimension_id
          },
          "dataType": 'script',
          "async": false
        })
        .then(function (res) {
          console.log("RESPONSE:", res)
          //$("#modal-container").html(add_edit_dimtree_form(res))
        })
        .catch(function (err) { console.log("ERROR:", err) })

      }
     }
   })
}



$(document).on('turbolinks:load', function(event, state) {
 initializeDrag();
})
initializeDrag();
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
    show_subject_dimensions = function (subj_abbr, page_title) {
      $('.subject-column').addClass('hidden')
    	$('#'+subj_abbr+'-dim-column').removeClass('hidden')
      $('#'+subj_abbr+'-lo-column').removeClass('hidden')
      connections_display(true)
      $('.show-hide-gradeband').addClass('option-selected');
      $('.dim-item').removeClass('hidden');
      document.cookie = page_title + "_subject_visible=" + subj_abbr;
    }

  /**
   * Expand and highlight LO and dimension connections.
   */
  connections_display = function (showall, rel, selected) {
    console.log(rel, selected)
    if ($(selected).hasClass('spotlight') || showall) {
	  	$('.dim-item--collapsable')
	  	  .removeClass('collapsed spotlight spotlight-akin show-connections-condition');
	    $('.dim-item--collapsable')
	  		.find('.connections-icon')
	  		.attr('title', 'show connections');
    }
    else {
      $('.dim-item--collapsable')
  	   .addClass('collapsed')
  	   .removeClass('spotlight spotlight-akin show-connections-condition')
       .find('.connections-icon')
       .attr('title', 'show connections');
	  	  for (var r in rel) {
	  	    $(rel[r]).removeClass('collapsed')
	  		   .addClass('spotlight-akin show-connections-condition');
	  	  }
      $(selected)
        .removeClass('collapsed')
        .addClass('spotlight show-connections-condition');
      $(selected)
         .find('.connections-icon')
         .attr('title', 'exit spotlight mode');
    }

  }

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


initializeDrag = function () {
   $('.dimension-page .list-group-item').draggable({
     revert: true,
     zIndex: 101,
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

      //find out if the item being dragged is of the same type as the
      //item it was dropped on.
      var types = [item_to_connect.dataset['loid'] == undefined, ui.helper[0].dataset['loid'] == undefined]
      //if an item is dropped on an item that is not of the same type
      if (item_to_connect != null && types[0] != types[1]) {
        var tree_id, dimension_id
        if (ui.helper[0].dataset['loid']) {
        	tree_id = ui.helper[0].dataset['loid']
          dimension_id = item_to_connect.id.split('_')[2]
        }
        else {
          tree_id = item_to_connect.id.split('_')[2]
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
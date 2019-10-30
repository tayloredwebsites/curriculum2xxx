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
  	$('.sequence-grid').removeClass('cols-0 cols-1 cols-2 cols-3 cols-4 cols-5')
  	$('.sequence-page .sequence-grid').addClass('cols-' + $('.subj-checkbox input:checked').length )
  }

  /**
   * Expand and highlight related LOs 
   */

  related_LO_display = function (rel) {
    if ($("#lo_" + rel[rel.length - 1]).hasClass('highlight')) {
	  	$('.sequence-item--collapsable')
	  	  .removeClass('collapsed highlight show-connections-condition');
	  	for (var r in rel) {
	  		$('li[data-lo-id='+rel[r]+']')
	  		 .find('.connections-icon')
	  		 .attr('title', 'highlight related LOs');
	  	}
    }
    else {
      $('.sequence-item--collapsable')
  	  .addClass('collapsed')
  	  .removeClass('highlight show-connections-condition');
	  	for (var r in rel) {
	  	  console.log('highlight ', rel[r])
	  	  $("#lo_" + rel[r])
	  		.removeClass('collapsed')
	  		.addClass('highlight show-connections-condition');
	       $("#lo_" + rel[r])
	  		 .find('.connections-icon')
	  		 .attr('title', 'exit highlight mode');
	  	}
    }
 
  }

 $('.list-group').sortable({
  placeholder: 'drop-placeholder',
  handle: '.sort-handle'
  })

// $('.list-group-item').draggable({
// placeholder: 'drop-placeholder',
// handle: '.connect-handle'
// })

});
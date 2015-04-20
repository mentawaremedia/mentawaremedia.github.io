$(document).ready( function() {
	$('.popoverel').popover();

	$('.reply_text').on('keyup', function(){
		var count = parseInt($(".count").data('originalcount')) - parseInt($(this).val().length);
		$('.count').text(count.toString());
		$('.count').toggleClass("errorText", count < 0);
		$(this).toggleClass("errorText", count < 0);
		$(".submit").toggleClass("disabled", count < 0);
		$(".submit").prop('disabled', (count < 0) ? true : false);
	});

	$("form input[type=submit]").on('click', function(){
		$("form input[type=submit]").each(function(){
			$(this).removeClass('activeBtn');
		});
		$(this).addClass('activeBtn');
	});
});

function validateReply(evt) {
  	if($("form").context.activeElement.value == "Reply")
  	{
	  if ($(".reply_text").val() === '') {
	  	$(".reply_text").stop(true, true).fadeOut(500).fadeIn(500);
	    return false;
	  } else {
	    return true;
	  }
	}
	else
	{
		return true;
	}
};

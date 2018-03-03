$(document).ready( function() {
	$('#expand').click( function() {
		$('#instructions').css('transform', 'translate(-200px, 0px)');
	});

	$('#expand').hover( function() {
		$(this).css({'color': '#111111', 'background-color': '#f1f1f1'});
		}, function() {
		$(this).css({'color': '#ffffff', 'background-color': '#000000'});
	});

	$('#contract').click( function() {
		$('#instructions').css('transform', 'translate(0px, 0px)');
	});

	$('#contract').hover( function() {
		$(this).css({'color': '#111111', 'background-color': '#f1f1f1'});
		}, function() {
		$(this).css({'color': '#ffffff', 'background-color': '#000000'});
	});
});
var color = ["black", "green", "blue", "red", "purple", "yellow", "orange"];
var turn = 1;

$(document).ready( function() {

	$('#expand').click( function() {
		$('#instructions').css('transform', 'translate(-500px, 0px)');
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

	$('#current').on('click', '.marbles', function() {
		var element = $(this);
		var class2 = element.attr('class').split(' ')[1];
		var input;
		switch (class2) {
			case "slot1":
				input = $('#input1');
				break;
			case "slot2":
				input = $('#input2');
				break;
			case "slot3":
				input = $('#input3');
				break;
			case "slot4":
				input = $('#input4');
		}
		toggleInput(input, element);
	});

});

function toggleInput(input, element) {
	var color = input.val();
	switch (color) {
		case "black":
			input.val("green");
			break;
		case "green":
			input.val("blue");
			break;
		case "blue":
			input.val("red");
			break;
		case "red":
			input.val("purple");
			break;
		case "purple":
			input.val("yellow");
			break;
		case "yellow":
			input.val("orange");
			break;
		case "orange":
			input.val("green");
	}
	toggleColor(element, input.val());
}

// toggles color to color of associated input
function toggleColor(element, color) {
	switch (color) {
		case "green":
			element.css('background', 'radial-gradient(circle at 33% 33%, #008000, #000000)');
			break;
		case "blue":
			element.css('background', 'radial-gradient(circle at 33% 33%, #0000FF, #000000)');
			break;
		case "red":
			element.css('background', 'radial-gradient(circle at 33% 33%, #FF0000, #000000)');
			break;
		case "purple":
			element.css('background', 'radial-gradient(circle at 33% 33%, #800080, #000000)');
			break;
		case "yellow":
			element.css('background', 'radial-gradient(circle at 33% 33%, #FFFF00, #000000)');
			break;
		case "orange":
			element.css('background', 'radial-gradient(circle at 33% 33%, #ffa500, #000000)');
	}
}

// Ensure that user places all 4 marbles
function validateForm() {
	var value1 = $('#input1').val();
	var value2 = $('#input2').val();
	var value3 = $('#input3').val();
	var value4 = $('#input4').val();
	if (value1 == "black" || value2 == "black" || value3 == "black" || value4 == "black") {
		alert("Please place all four marbles before submitting your guess!");
		return false;
	} else {
		return true;
	}
}
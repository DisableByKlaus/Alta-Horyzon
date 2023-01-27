$(document).ready(function(){
	window.addEventListener("message",function(event){
		if (event["data"]["show"] !== undefined){
			if (event["data"]["show"] == true){
				$("#displayRunners").css("display","block");
			} else {
				$("#displayRunners").css("display","none");
			}


			return
		}


		if (event["data"]["score"] !== undefined){
			if (event["data"]["score"] == true){
				$("#score").fadeIn(50);
				$("#score2").fadeIn(50);
			} else {
				$("#score").fadeOut(50);
				$("#score2").fadeOut(50);
			}


			return
		}		


		$("#displayRunners").html(`
			<div class="backc"></div>
			<div class="check">CHECKPOINTS</div><s>${event["data"]["checkpoint"]} /  ${event["data"]["maxcheckpoint"]}</s>
			<div class="backc2"></div>
			<div class="check2">Tempo</div><s> ${formatarNumero(parseInt(event["data"]["explosive"]))}s</s>
		`);


		$("#score").html(`
			<div id="pessoa">
				<div class="nome">${event["data"]["info"]} </div>
				<div class="id">${event["data"]["id"]}</div>
				<div class="sec">${formatarNumero(parseInt(event["data"]["time"]))}s</div>
			</div>
		`);

		$("#score2").html(`
			<div class="back"></div>
			<div class="pose">Voce ficou em</div>
			<div class="numero">${event["data"]["position"]}º</div>
		`);
	});
});
/* ----------FORMATARNUMERO---------- */
const formatarNumero = (n) => {
	var n = n.toString();
	var r = '';
	var x = 0;

	for (var i = n.length; i > 0; i--) {
		r += n.substr(i - 1, 1) + (x == 2 && i != 1 ? '.' : '');
		x = x == 2 ? 0 : x + 1;
	}

	return r.split('').reverse().join('');
}
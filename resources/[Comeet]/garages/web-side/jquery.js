$(document).ready(function () {
	window.addEventListener("message", function (event) {
		switch (event.data.action) {
			case "openNUI":
				updateGarages();
				$("body").css("display", "block");
				break;

			case "closeNUI":
				$("body").css("display", "none");
				break;
		}
	});

	document.onkeyup = function (data) {
		if (data.which == 27) {
			$.post("http://garages/close");
		}
	};
});
/* --------------------------------------------------- */
const updateGarages = () => {
	$.post("http://garages/myVehicles", JSON.stringify({}), (data) => {
		const nameList = data.vehicles.sort((a, b) => (a.name2 > b.name2) ? 1 : -1);
		$("#listaVeiculos").html(`
				${nameList.map((item) => (`
                    <div class="veiculo" data-name="${item.name}" id="ativada"> 
                        <div class="nameCar" id="ativada">${item.name}</div>
                        <div class="center">
                            <img src="assets/${item.name2}.png" alt="" id="fotoCarro" />
                        </div>
                    </div>
			`)).join("")}
		`);

		$("#showRoom").html(`
				${nameList.map((item) => (`
				<div id="nomeCarro"  data-name="${item.name}">${item.name}</div>
				<div class="center" style="margin-top: 25px; margin-left: -811px;">
					<img src="assets/${item.name2}.png" alt="" id="fotoCarro2" style="background-image: url('assets/${item.name2}.png'); background-repeat: no-repeat;" />
				</div>


				<div class="row">
					<div id="painel" style="margin-left: 55rem;">
					<div class="between">
						<div class="txtAbout">Motor :</div>
						<div class="price" id="engine">${item.engine}%</div>
					</div>
					<div class="between">
						<div class="txtAbout">Lataria :</div>
						<div class="price" id="latariapercent">${item.body}%</div>
					</div>
					<div class="between">
						<div class="txtAbout">Gasolina :</div>
						<div class="price" id="fuel">${item.fuel}%</div>
					</div>
					<div
						class="progressbar"
						style="display: flex; justify-content: space-between; font-size: 24px; margin-left: 369px; margin-top: -103px; height: 10px; width: ${item.engine}%; background-color: #c43726; border-radius: 20px;"
					>
					</div>
					<div
						class="progressbar"
						style="display: flex; justify-content: space-between; font-size: 24px; margin-left: 369px; margin-top: 37px; height: 10px; width: ${item.engine}%; background-color: #c43726; border-radius: 20px;"
					>
					</div>
					<div
						class="progressbar"
						style="display: flex; justify-content: space-between; font-size: 24px; margin-left: 369px; margin-top: 37px; height: 10px; width: ${item.engine}%; background-color: #c43726; border-radius: 20px;"
					>
					</div>
					<div
						class="backprogressbar"
						style="display: flex; justify-content: space-between; font-size: 24px; margin-left: 369px; margin-top: -10px; height: 10px; width: ${item.engine}%; background-color: #c4372678; border-radius: 20px;"
					>
					</div>
					<div
						class="backprogressbar"
						style="display: flex; justify-content: space-between; font-size: 24px; margin-left: 369px; margin-top: -10px; height: 10px; width: ${item.engine}%; background-color: #c4372678; border-radius: 20px;"
					>
					</div>
					<div
						class="backprogressbar"
						style="display: flex; justify-content: space-between; font-size: 24px; margin-left: 369px; margin-top: -10px; height: 10px; width: ${item.engine}%; background-color: #c4372678; border-radius: 20px;"
					></div>
				  </div>
			    </div>

			<div class="mainButtons" style="margin-left: 123vh;">
				<div class="button" id="retirar" style="margin-left: -16rem;">RETIRAR</div>
				<div class="button" id="guardar">GUARDAR</div>
			</div>
			`)).join("")}
		`);		


	});
}

/* --------------------------------------------------- */
$(document).on("click", "#nomeCarro", function () {
	let $el = $(this);
	let isActive = $el.hasClass("ativada");
	$(".veiculo").removeClass("ativada");
	if (!isActive) $el.addClass("ativada");
});

function guardar(nome) {
	//let $el = $(".vehicle.active").attr("data-name");
	//if ($el) {
		$.post("http://garages/spawnVehicles", JSON.stringify({ name: nome }));
		console.log(nome)
	//}
}
/* --------------------------------------------------- */
$(document).on("click", "#retirar", debounce(function () {
	let $el = $(".veiculo").attr("data-name");
	if ($el) {
		$.post("http://garages/spawnVehicles", JSON.stringify({ name: $el }));
		console.log($el)
	}
	console.log($el)
}));
/* --------------------------------------------------- */
$(document).on("click", "#guardar", function () {
	$.post("http://garages/deleteVehicles");
});
/* ----------DEBOUNCE---------- */
function debounce(func, immediate) {
	var timeout
	return function () {
		var context = this, args = arguments
		var later = function () {
			timeout = null
			if (!immediate) func.apply(context, args)
		}
		var callNow = immediate && !timeout
		clearTimeout(timeout)
		timeout = setTimeout(later, 200)
		if (callNow) func.apply(context, args)
	}
}
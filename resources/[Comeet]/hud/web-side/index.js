var tickInterval = undefined;
var lastHealth = 999;
var lastArmour = 999;
var lastStress = 999;
var lastHunger = 999;
var lastOxigen = 999;
var lastWater = 999;
// -------------------------------------------------------------------------------------------
$(document).ready(function(){
	window.addEventListener("message",function(event){
		if (event["data"]["progress"] == true){
			var timeSlamp = event["data"]["progressTimer"];

			if($(".ProgressBarProgress").css("display") === "flex"){
                $(".ProgressBarProgress").get(0).style.setProperty("--percent", "100");
				$(".ProgressBarProgress").css("display","none");
				clearInterval(tickInterval);
				tickInterval = undefined;

				return
			} else {
				$(".ProgressBarProgress").css("display","flex");
				$(".ProgressBarProgress").get(0).style.setProperty("--percent", "100");
			}

			var tickPerc = 100;
			var tickTimer = (timeSlamp / 100);
			tickInterval = setInterval(tickFrame,tickTimer);

			function tickFrame(){
				tickPerc--;

				if (tickPerc <= 0){
					clearInterval(tickInterval);
					tickInterval = undefined;
					$("#progressBackground").css("display","none");
				} else {
					timeSlamp = timeSlamp - (timeSlamp / tickPerc);
				}

				$("#textProgress").html(parseInt(timeSlamp / 1000));
				$("#progressDisplay").css("stroke-dashoffset",tickPerc);
			}

			return
		}
		
		if (event["data"]["mumble"] !== undefined){
			if (event["data"]["mumble"] == true){
				$("#Mumble").css("display","flex");
			} else {
				$("#Mumble").css("display","none");
			}

			return
		}

		if (event["data"]["hud"] !== undefined){
			if (event["data"]["hud"] == true){
				$(".subbase").css("display","flex");
			} else {
				$(".subbase").css("display","none");
			}

			return
		}

		if (event["data"]["movie"] !== undefined){
			if (event["data"]["movie"] == true){
				$("#movieTop").fadeIn(500);
				$("#movieBottom").fadeIn(500);
			} else {
				$("#movieTop").fadeOut(500);
				$("#movieBottom").fadeOut(500);
			}

			return
		}

		if (event["data"]["hood"] !== undefined){
			if (event["data"]["hood"] == true){
				$("#hoodDisplay").fadeIn(500);
			} else {
				$("#hoodDisplay").fadeOut(500);
			}
		}

        /*

		if (event["data"]["talking"] == true){
			$("#voice").css("background","#333 url(images/micOn.png)");
		} else {
			$("#voice").css("background","#222 url(images/micOff.png)");

			if (event["data"]["voice"] == 1){
				$(".voiceDisplay").css("stroke-dashoffset","75");
			} else if (event["data"]["voice"] == 2){
				$(".voiceDisplay").css("stroke-dashoffset","50");
			} else if (event["data"]["voice"] == 3){
				$(".voiceDisplay").css("stroke-dashoffset","25");
			} else if (event["data"]["voice"] == 4){
				$(".voiceDisplay").css("stroke-dashoffset","0");
			}
		}
        */
		if (lastHealth !== event["data"]["health"]){
			lastHealth = event["data"]["health"];

			if (event["data"]["health"] <= 1){
                $(".ProgressBarVida").get(0).style.setProperty("--percent", "18");
			} else {
                $(".ProgressBarVida").get(0).style.setProperty("--percent", event["data"]["health"]);
			}
		}

		$(".ProgressBarArmor").get(0).style.setProperty("--percent", event["data"]["armour"]);


		if (lastStress !== event["data"]["stress"]){
			lastStress = event["data"]["stress"];

			if (event["data"]["stress"] <= 0){
				if($(".stressBackground").css("display") === "block"){
					$(".stressBackground").css("display","none");
				}
			} else {
				if($(".stressBackground").css("display") === "none"){
					$(".stressBackground").css("display","block");
				}
			}

			$(".stressDisplay").css("stroke-dashoffset",100 - event["data"]["stress"]);
		}

        $(".ProgressBarSede").get(0).style.setProperty("--percent", event["data"]["thirst"]);

		
        $(".ProgressBarFome").get(0).style.setProperty("--percent", event["data"]["hunger"]);

		
		if (event["data"]["suit"] == undefined){
			if($(".oxigenBackground").css("display") === "block"){
				$(".oxigenBackground").css("display","none");
			}
		} else {
			if($(".oxigenBackground").css("display") === "none"){
				$(".oxigenBackground").css("display","block");
			}
		}

		if (lastOxigen !== event["data"]["oxigen"]){
			lastOxigen = event["data"]["oxigen"];

			$(".oxigenDisplay").css("stroke-dashoffset",100 - event["data"]["oxigen"]);
		}


		if (event["data"]["vehicle"] !== undefined){
			if (event["data"]["vehicle"] == true){
				if($("#hudcar").css("display") === "none"){
					$("#hudcar").css("display","block");
				}

					if (event["data"]["seatbelt"] == 1){
						$("#bottom-right-image").attr("src","https://cdn.discordapp.com/attachments/1022977507487645790/1055464584246472784/belt-green.png");
					} else {
						$("#bottom-right-image").attr("src","https://cdn.discordapp.com/attachments/1022977507487645790/1055464596133134386/seat-belt.png");

					}
				
					$("#progress-indicator").css("height",event["data"]["damageVehicle"]);

				$(".fuel").get(0).style.setProperty("--value", parseInt(event["data"]["fuel"]));

				//$(".bottom-right").html(parseInt(event["data"]["speed"]));
				organizar()

			} else {
				if($("#hudcar").css("display") === "block"){
					$("#hudcar").css("display","none");
				}
			}

		
		}

		function organizar(){
			let velo = document.querySelector('.bottom-right')
		
			velo.textContent = event["data"]["speed"]
		
			$(".bottom-right").html(parseInt(event["data"]["speed"]));
		
			if (Number(event.data.speed) <= 9) {
			  velo.innerHTML = `
				  <p class="bottom-right"> <span style="color: #572929;"> 00</span>${event["data"]["speed"].toFixed(0)}</p>
				`
			} else if (Number(event.data.speed) <= 99) {
			  velo.innerHTML = `
			  <p class="bottom-right"><span style="color: #572929;"> 0</span>${event["data"]["speed"].toFixed(0)}</p>
				`
			} else {
			  velo.innerHTML = `
			  <p class="bottom-right">${event["data"]["speed"].toFixed(0)}</p>
				`
			}
		}
	});



});





  // Get all the Meters
  const meters = document.querySelectorAll('svg[data-value] .meter');

  meters.forEach((path) => {
    // Get the length of the path
    let length = path.getTotalLength();
    // console.log(length) once and hardcode the stroke-dashoffset and stroke-dasharray in the SVG if possible 
    // or uncomment to set it dynamically
    // path.style.strokeDashoffset = length;
    // path.style.strokeDasharray = length;

    // Get the value of the meter
    let value = parseInt(path.parentNode.getAttribute('data-value'));
    // Calculate the percentage of the total length
    let to = length * ((100 - value) / 100);
    // Trigger Layout in Safari hack https://jakearchibald.com/2013/animated-line-drawing-svg/
    path.getBoundingClientRect();
    // Set the Offset
    path.style.strokeDashoffset = Math.max(0, to);
  });
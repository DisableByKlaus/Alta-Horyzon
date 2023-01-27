async function verifyConnection() {
  return navigator.onLine
}

var actualOpen = ""
var pesomaximo = 0

Global = {}
Global.Inventory = {}
Global.Inventory.MaxSlots = 54
Global.Inventory.Open = function(items,refresh,other,plyweight,title,chestweight,maxchestweight){
    if(!refresh){$('.inventory').fadeIn();}
	if (items.numslots){ Global.Inventory.MaxSlots = items.numslots }
    $('.settings-tab').hide()
    $('.player-quick').find('.item-box').remove()
    $('.player-pocket').find('.item-box').remove()
    $('.player-inventory').find('.item-box').remove()
    $('.other-inventory').find('.item-box').remove()
	
	$('.other-inventory').find('.item-box').remove()
	if (maxchestweight == null) { pesomaximo = 0 } 
    for(i=1;i<5+1;i++){//QuickItems
        $('.player-quick .player-quick-items').append(`<div data-slot="${i}" class="item-box"></div>`)
		$('#hotbar' + i).show();
    }

    for(i=7;i<12+1;i++){//Pocket Items
        $('.player-pocket .player-pocket-items').append(`<div data-slot="${i}" class="item-box"></div>`)
    }

    for(i=13;i<Global.Inventory.MaxSlots+13;i++){//Main-Inventory
        $('.player-inventory .player-items').append(`<div data-slot="${i}" class="item-box"></div>`)
    }
    for(i=1;i<(other != undefined && other.slots || Global.Inventory.MaxSlots)+1;i++){//Other-Inventory
        $('.other-inventory .other-items').append(`<div data-other-slot="${i}" class="item-box"></div>`)
    }
    if(other){
		actualOpen = other.id
		
        $('.cloth-inv').fadeOut();$('.crafting-inventory').fadeOut();$('.other-inventory').fadeIn().attr('data-inventory',other.id)
        $.each(other.items,function(k,v){
            if(v != null){
				var amount = ""
				if (other.id.startsWith("Shop-")){
					amount = "$"+kFormatter(v.amount)
				} else {
					amount = kFormatter(v.amount)
				}
				if (v.name && v.name.includes("|")){ v.name = v.name.replace("|", ""); }
                $('.inventory').find(`[data-other-slot="${v.slot}"]`).html(`
					<img src="items/assets/images/items/${v.name}.png">
                    <div class="item-amount">${amount}</div>
                `).attr('data-name',v.name).attr('data-label',v.itemName).attr('data-quality',v.totalweight).attr('data-type',v.type).attr('data-inventory',other.id).attr('data-rawamount',v.amount)
            }
        })
    }else{
		if (actualOpen != "playerInv" && actualOpen != ""){
			$.post('https://'+GetParentResourceName()+'/ChangedInventory',JSON.stringify({
				inventory: actualOpen,
			}))
			document.getElementById('amount').value = ''
		}
		actualOpen = "playerInv"
        $('.cloth-inv').fadeIn();$('.other-inventory').fadeOut();$('.crafting-inventory').fadeOut()
    }
	if (actualOpen == "" || actualOpen == "playerInv"){
		$('.inventory-weight-head-other').hide()
		$('.progress-bar-other').hide()
	}
    $.each(items,function(k,v){
		
        if(v != null){
			amount = kFormatter(v.amount)
			if (k <= 5){
				$('#hotbar' + k).hide();
			}
			if (v.item && v.item.includes("|")){ v.item = v.item.replace("|", ""); }
            $('.inventory').find(`[data-slot="${k}"]`).html(`
			<img src="items/assets/images/items/${v.name}.png">
                <div class="item-amount">${amount}</div>
            `).attr('data-name',v.item).attr('data-label',v.itemName).attr('data-quality',v.totalweight).attr('data-type',v.type).attr('data-rawamount',v.amount)
			
        }
    })
	
	
	if (title) {
		if (maxchestweight > 0){
			pesomaximo = maxchestweight
			$(".other-inventory-head").html(title.toUpperCase() + ' <span style="margin-left: 0.4vh;font-size:1.6vh;"><span style="opacity: 0.5;">' + chestweight.toFixed(2) + '</span> / ' + Math.ceil(maxchestweight) + '.0</span>');
		} else {
			$(".other-inventory-head").html(title.toUpperCase());
		}
	} else {
		$(".other-inventory-head").html();
	}
	$(".player-inventory-head").html('<img src="https://cdn.discordapp.com/attachments/1022977507487645790/1047952264561709136/unknown.png" style="margin-top: 3vh;margin-left: -0.9vw;" /> <span style="margin-left: 29.9vh;font-size:1.6vh;"><span style="opacity: 0.5;">' + items.invweight.toFixed(2) + '</span> <span style="color: red;"> /  </span>' + Math.ceil(plyweight) + '.0</span>');
    Global.Inventory.Utils()
}
Global.Inventory.Utils = function(){
    $('.item-box').each(function(){
        if($(this).data('name')){
            $(this).draggable({helper: 'clone',appendTo: ".inventory",revert: 'invalid',containment: 'document'})
        }
    })
    $(".item-box").droppable({
        hoverClass: 'button-hover',
        drop: function(event, ui) {
            if(!isOverflowing(event, $(this).parent().parent()) || $(this).parent().parent().attr('data-inventory') != 'player'){
				verifyConnection().then(success => {
					if (success) {
						var toinventory = $(this).parent().parent().attr('data-inventory')
						var frominventory = ui.draggable.parent().parent().attr('data-inventory')
						var amount = parseInt($('#amount').val());
						if (amount != 0 && $(this).data('name') == ui.draggable.data('name') || $(this).data('name') == undefined || amount == 0 || isNaN(amount) ){

							let nameOne = ""
							let nameTwo = ""

							if(frominventory == 'player' && toinventory == 'player'){
								nameOne = "slot"
								nameTwo = "slot"
								
								$.post('https://'+GetParentResourceName()+'/SetInventoryData',JSON.stringify({
									toslot:$(this).data('slot'),
									fromslot:ui.draggable.data('slot'),
									frominventory:frominventory,
									toinventory:toinventory,
									maxweight:pesomaximo,
									amount:amount
								}))
	
							}else if(frominventory == 'player' && toinventory != 'player'){
								nameOne = "other-slot"
								nameTwo = "slot"
								
								$.post('https://'+GetParentResourceName()+'/SetInventoryData',JSON.stringify({
									toslot:$(this).data('other-slot'),
									fromslot:ui.draggable.data('slot'),
									frominventory:frominventory,
									toinventory:toinventory,
									maxweight:pesomaximo,
									amount:amount
								}))
							}else if(frominventory != 'player' && toinventory == 'player'){
								nameOne = "slot"
								nameTwo = "other-slot"
								
								
								$.post('https://'+GetParentResourceName()+'/SetInventoryData',JSON.stringify({
									toslot:$(this).data('slot'),
									fromslot:ui.draggable.data('other-slot'),
									frominventory:frominventory,
									toinventory:toinventory,
									maxweight:pesomaximo,
									amount:amount
								}))
							}else if(frominventory != 'player' && toinventory != 'player'){
								nameOne = "other-slot"
								nameTwo = "other-slot"
								$.post('https://'+GetParentResourceName()+'/SetInventoryData',JSON.stringify({
									toslot:$(this).data('other-slot'),
									fromslot:ui.draggable.data('other-slot'),
									frominventory:frominventory,
									toinventory:toinventory,
									maxweight:pesomaximo,
									amount:amount
								}))
							}
							
							let itemAmount = parseInt(ui.draggable.data("rawamount"));
							let transfer = (isNaN(amount) | amount == "") ? itemAmount : amount;
							
							if(transfer <= itemAmount){
								
								let clone1 = ui.draggable.clone();
								let slot2 = $(this).data(nameOne); 
								
								if(transfer == itemAmount) {
									
									let clone2 = $(this).clone();
									let slot1 = ui.draggable.data(nameTwo);

									$(this).replaceWith(clone1);
									ui.draggable.replaceWith(clone2);
									
									$(clone1).data(nameOne, slot2);
									$(clone2).data(nameTwo, slot1);
								} else {
									let newAmountOldItem = itemAmount - transfer;
									let weight = parseFloat(ui.draggable.data("peso"));
									let newWeightClone1 = (transfer*weight).toFixed(2);
									let newWeightOldItem = (newAmountOldItem*weight).toFixed(2);

									ui.draggable.data("rawamount",newAmountOldItem);

									clone1.data("rawamount",transfer);

									$(this).replaceWith(clone1);
									$(clone1).data(nameOne,slot2);

									ui.draggable.children(".item-amount").html(kFormatter(ui.draggable.data("rawamount")));
									
									$(clone1).children(".item-amount").html(kFormatter(clone1.data("rawamount")));
								}
								
								Global.Inventory.Utils()
							}
							
						}
						
					}
				})
            }
        }
    });
	$(".item-box").click(function(event,ui) {
		if (event.detail === 2) {
			verifyConnection().then(success => {
				if (success) {
					$.post('https://'+GetParentResourceName()+'/UseItem',JSON.stringify({
						inventory: $(this).parent().parent().attr('data-inventory'),
						item: $(this).attr('data-slot'),
						qtd: parseInt($('#amount').val())
					}))
				}
			})
		}
	})
    $('.use-item').off().droppable({
        drop:function(event,ui){
			verifyConnection().then(success => {
				if (success) {
					$.post('https://'+GetParentResourceName()+'/UseItem',JSON.stringify({
						inventory: ui.draggable.parent().parent().attr('data-inventory'),
						item: ui.draggable.attr('data-slot'),
						qtd: parseInt($('#amount').val())
					}))
				}
			})
        }
    })
    $('.drop-item').off().droppable({
        drop:function(event,ui){
			verifyConnection().then(success => {
				if (success) {
					$.post('https://'+GetParentResourceName()+'/DropItem',JSON.stringify({
						inventory:ui.draggable.parent().parent().attr('data-inventory'),
						item:ui.draggable.attr('data-slot'),
						qtd: parseInt($('#amount').val())
					}))
				}
			})
        }
    })
	$('.send-item').off().droppable({
        drop:function(event,ui){
			verifyConnection().then(success => {
				if (success) {
					$.post('https://'+GetParentResourceName()+'/SendItem',JSON.stringify({
						inventory:ui.draggable.parent().parent().attr('data-inventory'),
						item:ui.draggable.attr('data-slot'),
						qtd: parseInt($('#amount').val())
					}))
				}
			})
        }
    })
    $('.cloth-items .item-box').off().click(function(){
        $.post('https://'+GetParentResourceName()+'/ChangeVariation',JSON.stringify({component:$(this).attr('id')}))
    })
    $('.crafting-toggle').off().click(function(){
		if ($('.cloth-inv').is(':visible') || $('.other-inventory').is(':visible')) {
			Global.Inventory.OpenCrafting();
			$.post('https://'+GetParentResourceName()+'/craftingtoggle',JSON.stringify())
		} else {
			$('.cloth-inv').fadeIn();$('.other-inventory').fadeOut();$('.crafting-inventory').fadeOut()
		}
	})
    $('#search').off().bind('input',function(){
        var value = $(this).val()
        $('.item-box').each(function(){
            if ($(this).parent().attr('class') != 'cloth-items'){
                if($(this).attr('data-label') && $(this).attr('data-label').toLowerCase().includes(value.toLowerCase())){
                    $(this).css('opacity','1.0')
                }else{
                    $(this).css('opacity','0.4')
                }
                if(value == '' || !value){
                    $(this).css('opacity','1.0')
                }
            }
        })
    })
    $('.item-box').each(function(){
        var name = $(this).attr('data-label')
        var amount = $(this).find('.item-amount').html()
		var rawAmount = $(this).attr('data-rawamount')
		var type = $(this).attr('data-type')
		var invType = $(this).attr('data-inventory')
		if (invType == null){ invType = "aleatorio" }

		
		var complete = ""
		if (type == "use"){
			complete = "<br/><br/>Clique <b><u>duas</u></b> vezes para utilizar"
		}
        if (name){
			$(this).attr('title',`
			<h>${name}<h>
			
			`
			).tooltip({content:$(this).attr('title'),track:true})
			if($(this).attr('data-quality')){
				if (invType.startsWith("Shop-")){
					
					var peso = $(this).attr('data-quality')/rawAmount
					$(this).attr('title',$(this).attr('title').toUpperCase()+`<span style="display:block;font-size:1.5vh">Preço: <b><span style="font-size:1.6vh">${amount}</span></b><br/>Peso: <b>${peso}</b>kg</span>`).tooltip({content:$(this).attr('title'),track:true})
				} else {
					if ($(this).attr('title') != undefined)
						$(this).attr('title',$(this).attr('title').toUpperCase()+`<span style="display:block;font-size:1.5vh">Quantidade: <b>${rawAmount}</b><br/>Peso: <b>${$(this).attr('data-quality')}</b>kg${complete}</span>`).tooltip({content:$(this).attr('title'),track:true})
				}
			}
        }
    })
    $('.settings i').off().click(function(){
        $('.settings-tab').fadeToggle()
        $('#tooltip-checkbox').off().change(function(){
            if($(this).prop('checked')){
                $('head').append(`<style id="head-tooltip-setting">.ui-tooltip{visibility: hidden;}</style>`)
            }else{
                $('#head-tooltip-setting').remove()
            }
        })
        $('#blur-checkbox').off().change(function(){
            if($(this).prop('checked')){
                $('.bg').css('backdrop-filter','blur(35vh)')
            }else{
                $('.bg').css('backdrop-filter','none')

            }
        })
    })
    //$(".item-amount").each(function(){var t=$(this).html().length;6==t?$(this).css({top:"1.7vh"}):5==t?$(this).css({top:"1.8vh"}):4==t?$(this).css({top:"1.9vh"}):3==t?$(this).css({top:"2.2vh"}):2==t?$(this).css({top:"2.5vh"}):1==t&&$(this).css({top:"2.7vh"})});
}
Global.Inventory.Close = function(){
	$.post('https://'+GetParentResourceName()+'/CloseInventory',JSON.stringify({
		inventory: actualOpen,
	}))
    $('.ui-tooltip').hide()
	document.getElementById('amount').value = ''
	actualOpen = ""
}
Global.Inventory.WeightProgress = function(value,maxvalue){
    AnimateWeight('.inventory-weight-head',value,maxvalue)
}
Global.Inventory.WeightProgressOther = function(value,maxvalue){
    AnimateWeight('.inventory-weight-head-other',value,maxvalue)
}
Global.Inventory.OpenCrafting = function() {
    $('.cloth-inv').fadeOut();$('.other-inventory').fadeOut()
    $('.crafting-inventory').fadeIn()
	$(".other-inventory-head").html('PRODUÇÃO');
    $('.crafting-inventory .crafting-items').html('')
    $.each(RecipeList,function(k,v){
        AddCraftingElement(k,v)
    })
}
var HotBarTimeOut
Global.Inventory.OpenHotbar = function(data){
    clearTimeout(HotBarTimeOut)
    $('.quick-hotbar').find('.item-box').remove()
    $('.quick-hotbar').fadeIn().animate({right:'1vw'})
    for(i=1;i<6;i++){
        $('.quick-hotbar').append(`
        <div data-hotbar-slot="${i}" class="item-box">
            <div class="item-hotbar-key">${i}</div>
        </div>
        `)
    }
    $.each(data,function(k,v){
        if(v){
			var put = k + 1
			if (v.item && v.item.includes("|")){ v.item = v.item.replace("|", ""); }
            $('.quick-hotbar').find(`[data-hotbar-slot=${put}]`).html(`
                <div class="item-hotbar-key">${put}</div>
                <img src="items/assets/images/items/${v.name}.png">
                <div class="item-amount">${v.amount}</div>
            `)
        }
    })
    HotBarTimeOut = setTimeout(function(){
        $('.quick-hotbar').animate({right:'-10vw'})
        $('.quick-hotbar').fadeOut()
    },3000)
}

function minTwoDigits(n) {
  return (n < 10 ? '0' : '') + n;
}

////UTILS 
AnimateWeight = async function(element,end,max) {
    $(element).animate({
        Counter: end
    }, {duration: 500,easing: 'swing',
        step: function (now) {
            $(this).html(`<span style="opacity: 0.5;">${now.toFixed(2)}</span> / ${Math.ceil(max)}.0`);
        }
    });
}
isOverflowing = function(event, $droppableContainer){
    var cTop = $droppableContainer.offset().top;var cLeft = $droppableContainer.offset().left;var cBottom = cTop + $droppableContainer.height();var cRight = cLeft + $droppableContainer.width();
    if (event.pageY >= cTop && event.pageY <= cBottom && event.pageX >= cLeft && event.pageX <= cRight){return false;}else{return true;}
}
AddCraftingElement = function(item,recipe){
	if (item && item.includes("|")){ item = item.replace("|", ""); }
    $('.crafting-inventory .crafting-items').prepend(`
        <div data-crafting-item="${item}" class="item-crafting">
            <div class="left">
                <div class="item-box">
					<img src="items/assets/images/items/${item}.png">
                </div>
				<div class="craft-button">

                </div>
                <div class="craft-button-text">
                    <i class="fas fa-hammer"></i>
                </div>
            </div>
            <div class="right"></div>
        </div>
    `)
    var craftingelement = $('.crafting-items').find(`[data-crafting-item=${item}]`)
	
    $.each(recipe,function(k,v){
		if (!v.perm) {
			if (v.name && v.name.includes("|")){ v.name = v.name.replace("|", ""); }
			craftingelement.find('.right').append(`
				<div class="recipe">
					<span>
					<img src="items/assets/images/items/${v.image}.png">
						${v.amount} ${v.label}
					</span>
				</div>
			`)
		}
        
    })
    craftingelement.off().find('.craft-button-text').click(function(){
        $.post('https://'+GetParentResourceName()+'/CraftItem',JSON.stringify({
            item:item,
            recipe:recipe
        }))
    })
}

window.addEventListener('message', function(event) {
    switch(event.data.action) {
        case 'open':
            Global.Inventory.Open(event.data.items,false,event.data.other,event.data.plyweight,event.data.title,event.data.weight,event.data.maxweight)

			if(event.data.backpack){
				$(".backpack").css("display", "none")
				console.log("true")
			}else{
				$(".backpack").css("display", "block")
				console.log("false")
			}
            break;
        case 'close':
			$('.ui-tooltip').hide()
            $('.inventory').fadeOut()
			if (actualOpen != "playerInv" && actualOpen != ""){
				$.post('https://'+GetParentResourceName()+'/ChangedInventory',JSON.stringify({
					inventory: actualOpen,
				}))
				document.getElementById('amount').value = ''
			}
			actualOpen = ""
			
            break;
        case 'refresh':
            Global.Inventory.Open(event.data.items,true,event.data.other,event.data.plyweight,event.data.title,event.data.weight,event.data.maxweight)
            break;
        case 'hotbar':
            Global.Inventory.OpenHotbar(event.data.items)
        break;


    }
})
$(document).on('keydown', function(event) {
    switch(event.keyCode) {
        case 27: // ESC
        Global.Inventory.Close()
		$(".cloth-items").css("display", "none")
		$(".imagems").css("display", "none")
        break;
    }
})

function kFormatter(n){
	if (parseInt(n) > 10000) {
		d = 2
		x=(''+n).length,p=Math.pow,d=p(10,d)
		x-=x%3
		return Math.round(n*d/p(10,x))/d+" kMGTPE"[x/3]
	} else {
		return n
	}
}

let MultasTotal = null
let inMultas = false

var saida = null
var ganho = null
var multa = null

$(document).ready(function(){
    window.addEventListener("message", function(event){

        switch(event.data.action){
            case 'opensystem':
                
                $.post("https://bank/getGraphic")

                $('bank_section').css('display','block')
                $('bankClose').css('display','none')
                $( "#secundario" ).removeClass( "active option" ).addClass( "option" );
                $( "#ativo" ).removeClass( "option" ).addClass( "active option" );
                
                $('.left-section').fadeIn(0)
                $('#maskbank').fadeIn(0)
                $('#maskmultas').fadeOut(0)


                
                $carteiradiv = `<div class="carteirada">$${event.data.carteira}</div>`
                $bancodiv = ` <div class="bancada">$${event.data.banco}</div>`
                $nome = ` <div class="nome">${event.data.gemas}</div>`
                $gemas = ` <div class="gemasda">${event.data.infos}</div>`
                $('.nomes').html($nome)
                $('.carteiradas').html($carteiradiv)
                $('.bancadas').html($bancodiv)
                $('.gemas').html($gemas)
            break
                case 'closedbank':
                    $('bankClose').css('display','block')
                break
            case 'closesystem':
                $('bank_section').css('display','none')
                $('bankClose').css('display','none')
            break

            case 'recebimentos':

                $('.content-rendimentos').prepend(`
                <div class="item">
                    <div class="icon flex">+</div>
                    <span>R$ ${event.data.valor}</span>
                    <small>Seu ${event.data.text}<br> Já está disponivel no seu saldo!</small>
                </div>
                
                `)
            break

            case 'Graphic':

                saida = 0
                ganho = 0
                multa = 0

                $('.transferencias-active').empty()

                var dados = event.data.dados
                if(dados != "undefined" && dados != null){
                    $('.transferencias-active').empty()
                    dados.forEach((key,value) => {

                        if(key.Desc == 'saida'){
                            saida = parseInt(saida) + parseInt(key.Valor)
                            $('.transferencias-active').append(`
                            <div class="extract-item" style="/* display: flex; */font-size: 16px;margin-top: 30px;">
                                <div class="extract-icon flex">
                                    <div class="text-icon" style="">
                                        <a style="font-weight: 300 !important;color: #8326c7;">${key.Text}</a>
                                        <span> -R$ ${key.Valor},00</span><small></small>
                                    </div>
                                </div>
                            </div>
                        `)
                            

                        }else if(key.Desc == 'entrada'){
                            ganho = parseInt(ganho) + parseInt(key.Valor)
                            $('.transferencias-active').append(`
                            <div class="extract-item" style="/* display: flex; */font-size: 16px;margin-top: 30px;">
                                <div class="extract-icon flex">
                                    <div class="text-icon" style="">
                                        <a style="font-weight: 300 !important;color: #8326c7;">${key.Text}</a>
                                        <span> +R$ ${key.Valor},00</span><small></small>
                                    </div>
                                </div>
                            </div>
                        `)
                        
                            
                        }else if(key.Desc == 'multas'){
                            multa = parseInt(multa) + parseInt(key.Valor)
                        }
                    });
                }else{
                    saida = 0
                    ganho = 0
                    multa = 0
                }
            
            case 'updateaccount':
                $carteiradiv = `<span id="limit"><small>$</small> ${event.data.wallet} / <span style="color:white;" id="limit-max"><small>$</small>${event.data.bank}</span></span>`
                $('.saldodiv').html($carteiradiv)
                break

                
        
            }
        document.onkeyup = function(data){
            if(data.which == 27) {
                $.post("https://bank/fecharbanco")
                closeModal()
                inMultas = false
                $('.content-traffic').empty()
            }
        }
    })
})


function SendMulta(){

    let passaporte = document.querySelector('#passaporte').value
    let valormulta = document.querySelector('#valormulta').value
    let reason = document.querySelector('#reason').value
    let desc = document.querySelector('#desc').value

    if(valormulta > 0 ) {
        if(passaporte == '' | passaporte == " " | valormulta == '' | valormulta == " " | reason == '' | reason == " " | desc == '' | desc == " "){
            return
        }
        closeModalPix()
        $.post("https://bank/multas",JSON.stringify({
            type: 'apply',
            id: passaporte,
            value: valormulta,
            reason: reason,
            desc: desc
        }));
    }
}

// BOTAO SACAR,BOTAO DEPOSITAR,BOTAO SAQUE RÁPIDO

function closeModalPix(){
    closeModal()
    $.post("https://bank/fecharbanco")
}

function depositar(){

    $depositar = `<modal style="display:block;" id="modalDeposito" class="modalOpen">
                    <div class="title">Depositar</div>
                    <div class="modal-input">
                        <label>Quantidade R$</label>
                        <input type="number" id="valueDeposit" placeholder="EX: 500,000">
                    </div>
                    <button id="confirm" onclick="DepositMoney()"><svg class="svg-inline--fa fa-check fa-w-16 icon" aria-hidden="true" focusable="false" data-prefix="far" data-icon="check" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg=""><path fill="currentColor" d="M435.848 83.466L172.804 346.51l-96.652-96.652c-4.686-4.686-12.284-4.686-16.971 0l-28.284 28.284c-4.686 4.686-4.686 12.284 0 16.971l133.421 133.421c4.686 4.686 12.284 4.686 16.971 0l299.813-299.813c4.686-4.686 4.686-12.284 0-16.971l-28.284-28.284c-4.686-4.686-12.284-4.686-16.97 0z"></path></svg><!-- <i class="far fa-check icon"></i> Font Awesome fontawesome.com --> </button>
                    <button id="cancelar" onclick="closeModal()"><svg class="svg-inline--fa fa-times fa-w-11 icon" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="times" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 352 512" data-fa-i2svg=""><path fill="currentColor" d="M242.72 256l100.07-100.07c12.28-12.28 12.28-32.19 0-44.48l-22.24-22.24c-12.28-12.28-32.19-12.28-44.48 0L176 189.28 75.93 89.21c-12.28-12.28-32.19-12.28-44.48 0L9.21 111.45c-12.28 12.28-12.28 32.19 0 44.48L109.28 256 9.21 356.07c-12.28 12.28-12.28 32.19 0 44.48l22.24 22.24c12.28 12.28 32.2 12.28 44.48 0L176 322.72l100.07 100.07c12.28 12.28 32.2 12.28 44.48 0l22.24-22.24c12.28-12.28 12.28-32.19 0-44.48L242.72 256z"></path></svg><!-- <i class="fas fa-times icon"></i> Font Awesome fontawesome.com --> </button>

                </modal>`
    $('.clasediv').html($depositar)
    $('.wrap').css('filter','blur(3px)')
}

function sacar(){

    $sacar = `<modal style="display:block;" id="modalDrop" class="modalOpen">
                <div class="title">Sacar</div>
                <div class="modal-input">
                    <label>Quantidade R$</label>
                    <input type="number" id="valueDrop" placeholder="EX: 500,000">
                </div>
                <button id="confirm" onclick="spawnMoney()"><svg class="svg-inline--fa fa-check fa-w-16 icon" aria-hidden="true" focusable="false" data-prefix="far" data-icon="check" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg=""><path fill="currentColor" d="M435.848 83.466L172.804 346.51l-96.652-96.652c-4.686-4.686-12.284-4.686-16.971 0l-28.284 28.284c-4.686 4.686-4.686 12.284 0 16.971l133.421 133.421c4.686 4.686 12.284 4.686 16.971 0l299.813-299.813c4.686-4.686 4.686-12.284 0-16.971l-28.284-28.284c-4.686-4.686-12.284-4.686-16.97 0z"></path></svg><!-- <i class="far fa-check icon"></i> Font Awesome fontawesome.com --> </button>
                <button id="cancelar" onclick="closeModal()"><svg class="svg-inline--fa fa-times fa-w-11 icon" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="times" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 352 512" data-fa-i2svg=""><path fill="currentColor" d="M242.72 256l100.07-100.07c12.28-12.28 12.28-32.19 0-44.48l-22.24-22.24c-12.28-12.28-32.19-12.28-44.48 0L176 189.28 75.93 89.21c-12.28-12.28-32.19-12.28-44.48 0L9.21 111.45c-12.28 12.28-12.28 32.19 0 44.48L109.28 256 9.21 356.07c-12.28 12.28-12.28 32.19 0 44.48l22.24 22.24c12.28 12.28 32.2 12.28 44.48 0L176 322.72l100.07 100.07c12.28 12.28 32.2 12.28 44.48 0l22.24-22.24c12.28-12.28 12.28-32.19 0-44.48L242.72 256z"></path></svg><!-- <i class="fas fa-times icon"></i> Font Awesome fontawesome.com --> </button>

            </modal>`
    $('.clasediv').html($sacar)
    $('.wrap').css('filter','blur(3px)')
}

function closeModal(){
    $('.modalOpen').fadeOut(1)
    $('.wrap').css('filter','blur(0px)')
}




// SACAR,DEPOSITAR,SAQUE RÁPIDO
function spawnMoney() {
    let money  = document.querySelector('#valueDrop').value
 
    if(money > 0){
        closeModal()
        $.post("https://bank/money",JSON.stringify({
            type: 'drop',
            param: money,
        }),(data) => {
            if(data.retorno == 'sucesso'){
                $.post("https://bank/getGraphic")
            }
        });
    }
}
function DepositMoney() {
    let money = document.querySelector('#valueDeposit').value
    if(money > 0){
        closeModal()
        $.post("https://bank/money",JSON.stringify({
            type: 'deposit',
            param: money,
        }),(data) => {
            if(data.retorno == 'depositar'){
                $.post("https://bank/getGraphic")
            }
        });
    }
}
function ExpressSaque() {

    closeModal()
    $.post("https://bank/money",JSON.stringify({
        type: 'express'
        }),(data) => {
            if(data.retorno == '1000'){
                $.post("https://bank/getGraphic")
            }
        });
}

function open_transferencias() {

    $sendmoney = `
    <modal style="display:block;height: 40%;" id="modalDeposito" class="modalOpen">
        <div class="title">PIX</div>
        <div class="modal-input">
            <label>ID:</label>
            <input id="textid" maxlength="10" placeholder="EX: 225">
            <label>VALOR DA TRANSFERENCIA</label>
            <input type="number" id="valueTed" placeholder="EX: 500,000">
        </div>
        <button id="confirm" onclick="SendMoney()"><svg class="svg-inline--fa fa-check fa-w-16 icon" aria-hidden="true" focusable="false" data-prefix="far" data-icon="check" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg=""><path fill="currentColor" d="M435.848 83.466L172.804 346.51l-96.652-96.652c-4.686-4.686-12.284-4.686-16.971 0l-28.284 28.284c-4.686 4.686-4.686 12.284 0 16.971l133.421 133.421c4.686 4.686 12.284 4.686 16.971 0l299.813-299.813c4.686-4.686 4.686-12.284 0-16.971l-28.284-28.284c-4.686-4.686-12.284-4.686-16.97 0z"></path></svg><!-- <i class="far fa-check icon"></i> Font Awesome fontawesome.com --> </button>
        <button id="cancelar" onclick="closeModal()"><svg class="svg-inline--fa fa-times fa-w-11 icon" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="times" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 352 512" data-fa-i2svg=""><path fill="currentColor" d="M242.72 256l100.07-100.07c12.28-12.28 12.28-32.19 0-44.48l-22.24-22.24c-12.28-12.28-32.19-12.28-44.48 0L176 189.28 75.93 89.21c-12.28-12.28-32.19-12.28-44.48 0L9.21 111.45c-12.28 12.28-12.28 32.19 0 44.48L109.28 256 9.21 356.07c-12.28 12.28-12.28 32.19 0 44.48l22.24 22.24c12.28 12.28 32.2 12.28 44.48 0L176 322.72l100.07 100.07c12.28 12.28 32.2 12.28 44.48 0l22.24-22.24c12.28-12.28 12.28-32.19 0-44.48L242.72 256z"></path></svg><!-- <i class="fas fa-times icon"></i> Font Awesome fontawesome.com --> </button>

    </modal>`
    $('.clasediv').html($sendmoney)
    $('.wrap').css('filter','blur(3px)')

}


function SendMoney(){

    closeModal()
    let tedid = document.querySelector('#textid').value
    let tedvalue = document.querySelector('#valueTed').value

    if(tedid > 0 ) {
        if(tedid == '' | tedid == " "){
            return
        }else if(tedvalue == '' | tedvalue == " "){
            return
        }
        $.post("https://bank/money",JSON.stringify({
            type: 'send',
            id: tedid,
            value: tedvalue
        }),(data) => {
            if(data.retorno == 'ted'){
                $.post("https://bank/getGraphic")
            }
        });
    }
}

function clear_trans() {

    
    

    $.post("https://bank/clearTrans",JSON.stringify({}),(data) => {
        if(data.retorno == 'sucesso'){
            $.post("https://bank/getGraphic")
        }
    });

}

function activeTraffic(action){
         if(action.dataset.id == "h_banco"){
            $( "#secundario" ).removeClass( "active option" ).addClass( "option" );
            $( "#ativo" ).removeClass( "option" ).addClass( "active option" );
        }
}





local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

rfx = {}
Tunnel.bindInterface(GetCurrentResourceName(), rfx)


vRP.prepare("ConsultBank", "SELECT * FROM summerz_characters WHERE id = @user_id")
vRP.prepare("ConsultMoneyBank", "SELECT bank FROM summerz_characters WHERE id = @user_id")
vRP.prepare("UpdateMoneyBank", "UPDATE summerz_characters SET bank = @bank WHERE id = @user_id")


vRP.prepare("ConsultPix", "SELECT * FROM summerz_characters WHERE pix = @pix")
vRP.prepare("UpdateBankPix", "UPDATE summerz_characters SET pix = @pix WHERE id = @id")

vRP.prepare("getUserExtract", "SELECT * FROM summerz_extracts WHERE user_id = @user_id")
vRP.prepare("insertUserExtract","INSERT INTO summerz_extracts (user_id,valor,descricao,text) VALUES (@user_id,@valor,@descricao,@text)")
vRP.prepare("DeleteUserExtract","DELETE FROM summerz_extracts WHERE user_id = @user_id")



function rfx.ClearTrans()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        vRP.execute("DeleteUserExtract",{user_id = user_id})
        return true
    end
end

function rfx.getExtract()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local total = {}
        local extrato = vRP.query("getUserExtract", {user_id = user_id})
        if extrato[1] then
            for k,v in pairs(extrato) do
                table.insert(total,{Valor = v.valor, Desc = v.descricao, Text = v.text})
            end
            return total
       end
    end
end
 
function rfx.DropMoney(args)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local BankMoney = parseInt(vRP.getBank(user_id))
        if parseInt(args) <= BankMoney then 
            vRP.paymentBank(user_id,parseInt(args))
            vRP.giveInventoryItem(user_id, "dollars",parseInt(args),1)

            TriggerClientEvent("bank:notify",source,"sucesso","Você sacou R$:"..args.." para sua carteira!","Sucesso")
            vRP.execute("insertUserExtract",{user_id = user_id, valor = parseInt(args), descricao = 'saida', text = 'SAQUE'})
            return true
        else
            TriggerClientEvent("bank:notify",source,"negado","Valor excede o seu dinheiro do banco","Negado")
        end
    end
end



 
function rfx.DepositMoney(amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local value = parseInt(amount)

		if parseInt(value) > 0 then
			if  vRP.tryGetInventoryItem(user_id,"dollars",value) then
				vRP.addBank(user_id,value)
                print(value)
                TriggerClientEvent("bank:notify",source,"sucesso","Você depositou R$:"..value.." para seu banco!","Sucesso")
                vRP.execute("insertUserExtract",{user_id = user_id, valor = value, descricao = 'entrada', text = 'DEPOSITO'})
			else
				TriggerClientEvent("Notify",source,"vermelho","Dólares insuficientes.",5000)
			end
		end
	end
end

function rfx.Send(id,valor)
    local source = source
    local user_id = vRP.getUserId(source)
    local Player = vRP.query("ConsultBank", {user_id = parseInt(id)})
    local nuser_id = vRP.userSource(id)
    if user_id and nuser_id then
        
        if Player[1] then
            if nuser_id ~= user_id then
                local banco = parseInt(vRP.getBank(user_id))
                local nBanco = parseInt(vRP.getBank(id))

                if parseInt(valor) <= banco then
                    vRP.paymentBank(user_id,valor)
                    vRP.addBank(id,valor)
                    

                    TriggerClientEvent("Notify",source,"verde","Você enviou R$:"..parseInt(valor).." para o passaporte "..id.."",5000)

                    vRP.execute("insertUserExtract",{user_id = user_id, valor = parseInt(valor), descricao = 'saida', text = 'PIX'})
                    vRP.execute("insertUserExtract",{user_id = nuser_id, valor = parseInt(valor), descricao = 'entrada', text = 'PIX'})

                    return true
                else
                    TriggerClientEvent("Notify",source,"vermelho","Valor excede o seu dinheiro na carteira",5000)
                end
            else
                TriggerClientEvent("Notify",source,"vermelho","Você não pode enviar dinheiro para sí mesmo!",5000)
            end
        else
            TriggerClientEvent("Notify",source,"vermelho","passaporte inválido ou inexistente!",5000)
        end
    else
        TriggerClientEvent("Notify",source,"vermelho","Não encontramos essa pessoa no radar!",5000)
    end
end
 

function rfx.ConsultPlayer()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local banco = vRP.getBank(user_id)
        local carteira = vRP.getInventoryItemAmountOnly(user_id, "dollars") or 0
        return carteira,banco
    end
end 

  

function rfx.GetMoneySystem()
    local source = source
    local user_id = vRP.getUserId(source)
    local carteira = vRP.getInventoryItemAmountOnly(user_id, "dollars")
    local banco = vRP.getBank(user_id)
    return carteira,banco
end

function rfx.PlayerSystem()
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.userIdentity(user_id)
    local gemas = parseFormat(vRP.userGemstone(user_id))
    return gemas,{identity.name.." "..identity.name2}
end



 
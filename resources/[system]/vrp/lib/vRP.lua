local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vRP.getUserSource = vRP.userSource
vRP.user_tables = vRP.userTables
vRP.getBankMoney = vRP.getBank
vRP.setBankMoney = vRP.addBank
vRP.tryDeposit = vRP.paymentBank
vRP.tryWithdraw = vRP.withdrawCash
vRP.hasPermission = vRP.hasGroup
vRP.getUserIdentity = vRP.userIdentity
vRP.tryPayment = vRP.paymentFull



if vRP.getUserSource or vRP.user_tables or vRP.getBankMoney or vRP.setBankMoney or vRP.tryDeposit or vRP.hasPermission or vRP.getUserIdentity or vRP.tryPayment then print("o script "..GetCurrentResourceName().." usa vRP padrao, e foi efetuado a adptacao para a alta horyzon!") end

--[[
    Adicionar no inicio do script no inicio do script
    local adptar = module("vrp","lib/vRP")
    SERVER-SIDE!!
]]
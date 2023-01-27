local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
config = {}
Proxy.addInterface("vrp_inventory_items", config)

-------------------------------------------------------------------------------------------------------------------------
-- LISTA DE ITEMS
-------------------------------------------------------------------------------------------------------------------------
config.itemList = {
	--[ GERAL ]------------------------------------------------------------------------------------------
	['mochila'] = { ['index'] = 'mochila', ['name'] = 'Mochila Pequena', ['type'] = 'use', ['weight'] = 0.001 },
	['toolbox'] = { ['index'] = 'toolbox', ['name'] = 'Kit de Reparos', ['type'] = 'use', ['weight'] = 0.5 },
	['colete'] = { ['index'] = 'colete', ['name'] = 'Colete Balístico', ['type'] = 'use', ['weight'] = 0.5 },
	['skate'] = { ['index'] = 'skate', ['name'] = 'Skate', ['type'] = 'use', ['weight'] = 0.001 },
	
	
	['cola'] = { ['index'] = 'cola', ['name'] = 'Coca-Cola', ['type'] = 'use', ['weight'] = 0.5 },
	
	['water'] = { ['index'] = 'water', ['name'] = 'Água', ['type'] = 'use', ['weight'] = 0.5 },
	['dirtywater'] = { ['index'] = 'dirtywater', ['name'] = 'Água Suja', ['type'] = 'use', ['weight'] = 0.5 },
	['emptybottle'] = { ['index'] = 'emptybottle', ['name'] = 'Garrafa Vazia', ['type'] = 'use', ['weight'] = 0.5 },
	
	['dollars'] = { ['index'] = 'dinheiro', ['name'] = 'Dinheiro', ['type'] = 'normal', ['weight'] = 0.0 },
	['identity'] = { ['index'] = 'identity', ['name'] = 'Identidade', ['type'] = 'normal', ['weight'] = 0.5 },
	
	['roupas'] = { ['index'] = 'roupas', ['name'] = 'Roupas', ['type'] = 'normal', ['weight'] = 0.001 },
	['mascara'] = { ['index'] = 'mascara', ['name'] = 'Máscara', ['type'] = 'normal', ['weight'] = 0.001 },

	['animalpelt'] = { ['index'] = 'animalpelt', ['name'] = 'Couro', ['type'] = 'normal', ['weight'] = 0.001 },
	['elastic'] = { ['index'] = 'elastic', ['name'] = 'Elástico', ['type'] = 'normal', ['weight'] = 0.001 },
	['tarp'] = { ['index'] = 'tarp', ['name'] = 'Tecido', ['type'] = 'normal', ['weight'] = 0.001 },
	
	['nails'] = { ['index'] = 'nails', ['name'] = 'Pregos', ['type'] = 'normal', ['weight'] = 0.001 },
	['aluminum'] = { ['index'] = 'aluminum', ['name'] = 'Alumínio', ['type'] = 'normal', ['weight'] = 0.001 },
	['copper'] = { ['index'] = 'copper', ['name'] = 'Cobre', ['type'] = 'normal', ['weight'] = 0.001 },
	['metalcan'] = { ['index'] = 'metalcan', ['name'] = 'Sucata', ['type'] = 'normal', ['weight'] = 0.001 },
	
	--[ ARMAS ]------------------------------------------------------------------------------------------
	['glock'] = { ['index'] = 'glock', ['name'] = 'Glock-19', ['type'] = 'weapon', ['weight'] = 1.0, ['unique'] = true },
	
	['ak47'] = { ['index'] = 'ak47', ['name'] = 'AK-47', ['type'] = 'weapon', ['weight'] = 1.0, ['unique'] = true },
	['m4a1'] = { ['index'] = 'm4a1', ['name'] = 'M4A1', ['type'] = 'weapon', ['weight'] = 1.0, ['unique'] = true },
	
	['battleaxe'] = { ['index'] = 'battleaxe', ['name'] = 'Machado de Batalha', ['type'] = 'weapon', ['weight'] = 1.0, ['unique'] = true },
	
	['rifleammo'] = { ['index'] = 'rifleammo', ['name'] = 'Munição de Rifle', ['type'] = 'ammo', ['weight'] = 0.01 },
	['pistolammo'] = { ['index'] = 'pistolammo', ['name'] = 'Munição de Pistola', ['type'] = 'ammo', ['weight'] = 0.000001 },
	

	--[ ATTACHS ]------------------------------------------------------------------------------------------------
	['attachsflashlight'] = { ['index'] = 'attachsflashlight', ['name'] = 'Lanterna Bélica', ['type'] = 'use', ['weight'] = 0.01 },
	['attachsgrip'] = { ['index'] = 'attachsgrip', ['name'] = 'Empunhadeira', ['type'] = 'use', ['weight'] = 0.01 },
	['attachscrosshair'] = { ['index'] = 'attachscrosshair', ['name'] = 'Mira', ['type'] = 'use', ['weight'] = 0.01 },
	['attachssilencer'] = { ['index'] = 'attachssilencer', ['name'] = 'Silenciador', ['type'] = 'use', ['weight'] = 0.01 },
	['attachsmagazine'] = { ['index'] = 'attachsmagazine', ['name'] = 'Carregador Extendido', ['type'] = 'use', ['weight'] = 0.01 },
}

-- RETORNA A LISTA DE ITEMS (não mexa)
config.getItemList = function()
	return config.itemList
end

-------------------------------------------------------------------------------------------------------------------------
-- ARMAS
-------------------------------------------------------------------------------------------------------------------------
config.weapons = {
	-- INDEX = index da lista acima, NOMEMUNICAO = index do item da munição na lista acima, -- PERM = caso tenha esse atributo, apenas conseguirá equipar/desequipar/guardar em algum baú quem tiver essa permissão.
    ['WEAPON_COMBATPISTOL'] = {index = "glock", nomeMunicao = 'pistolammo'},
	['WEAPON_ASSAULTRIFLE'] = {index = "ak47", nomeMunicao = 'rifleammo'},
	['WEAPON_CARBINERIFLE'] = {index = "m4a1", nomeMunicao = 'rifleammo', perm = "policia.permissao"},
	
	['WEAPON_BATTLEAXE'] = {index = "battleaxe", nomeMunicao = nil},
}

-------------------------------------------------------------------------------------------------------------------------
-- BAÚS / configuração dos baús
-------------------------------------------------------------------------------------------------------------------------
config.chests = {
	config = {
		enableCustom = true,
		size = {0.7, 0.7, 0.7},
		rotate = {90.0, 90.0, 0.0},
		image = "cofre4", -- cofre,cofre2,cofre3,cofre4,cofre5
		
		blipDist = 6.0,
		buttonDist = 2.2,
		
		---------CASO ESTEJA DESATIVADO O CUSTOM---------
		notCustom = function(x,y,z,chest,distance)
			if distance < 2.5 then
				DrawText3D(x,y,z+1.0, "~b~[E]~w~ ACESSAR BAÚ ~b~"..string.upper(chest).."~w~.")
			end
		
			DrawMarker(2, x,y,z+0.75, 0, 0, 0, 0, 0, 0, 0.2, 0.2, 0.2, 255, 255, 255, 180, 0, 0, 2, 1, 0, 0, 0) -- seta
			
			DrawMarker(25, x,y,z+0.01, 0, 0, 0, 0, 0, 0, 0.9, 0.9, 0.5, 255, 255, 255, 180, 0, 0, 2, 1, 0, 0, 0) -- baixo
			DrawMarker(25, x,y,z+0.01, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 19, 126, 138, 280, 0, 0, 2, 1, 0, 0, 0) -- baixo contorno azul
		end
	},
	list = {
		['Roxos'] = { ['x'] = 161.53, ['y'] = -985.91, ['z'] = 30.1, ['weight'] = 5000, ['slots'] = 72, ['perm'] = 'ballas.permissao', ['webhook'] = '' },
	}
}

-------------------------------------------------------------------------------------------------------------------------
-- SHOPS / configuração dos shops
-------------------------------------------------------------------------------------------------------------------------
config.shops = {
	config = {
		enableCustom = false,
		size = {0.7, 0.7, 0.7},
		rotate = {90.0, 90.0, 0.0},
		image = "shop", -- shop, shop2
		
		blipDist = 6.0,
		buttonDist = 2.2,
		
		---------CASO ESTEJA DESATIVADO O CUSTOM---------
		notCustom = function(x,y,z,chest,distance)
			if distance < 2.5 then
				DrawText3D(x,y,z+1.0, "~b~[E] ~w~"..string.upper(chest).."~w~.")
			end
			DrawMarker(2, x,y,z+0.75, 0, 0, 0, 0, 0, 0, 0.2, 0.2, 0.2, 255, 255, 255, 180, 0, 0, 2, 1, 0, 0, 0) -- seta
		end
	},
	list = {
		["Loja de Conveniência"] = {
			mode = "Both", -- Buy (apenas compras), Sell (apenas venda), Both (compra E venda)
			payment = {
				item = "dollars", -- Caso seja SELL ou BOTH, esse será o item de pagamento.
				tax = 0.8, -- Quanto recebe do valor do item total, ao vender 
			},
			webhook = "",
			coords = {
				[1] = vec3(25.75, -1346.68, 29.5),
				[2] = vec3(-47.71, -1757.23, 29.43)
			},
			list = {
				["cola"] = 60,
				["water"] = 5000,
				["toolbox"] = 3500,
				["mochila"] = 3000
			}
		},
		["Ammunation"] = {
			mode = "Buy", -- Buy (apenas compras), Sell (apenas venda), Both (compra E venda)
			payment = {
				item = "dollars", -- Caso seja SELL ou BOTH, esse será o item de pagamento.
				tax = 0.8, -- Quanto recebe do valor do item total, ao vender 
			},
			webhook = "",
			coords = {
				[1] = vec3(21.76, -1106.64, 29.8),
			},
			list = {
				["ak47"] = 25000,
				["m4a1"] = 30000,
				["battleaxe"] = 25000,
				["rifleammo"] = 200,
			}
		},
	}
}

-------------------------------------------------------------------------------------------------------------------------
-- REVISTAR
-------------------------------------------------------------------------------------------------------------------------
config.revistar = {
	enableCarry = false, -- Ao revistar, carregar o player?
	time = 10 -- Tempo para efetuar a revista
}

config.blockCommands = 'cancelando' -- evento para travar os comandos do player

config.debugMode = false -- ativar mensagens do debug (não mexa)

config.base = "creative" -- defina se sua base é creative ou vrpex

config.events = { -- defina com o nome dos eventos da sua base
	enter = "vRP:playerSpawn",
	leave = "vRP:playerLeave"
}

config.customizationPath = 1 -- caso tenha dúvidas, consulte

config.giveWeaponType = "2" -- 1 ou 2 (1 = vRP.giveWeapons, 2 = função nativa)

config.webhooks = {
	portamalas = "",
	portaluvas = "",
	baucasas = "",
	dropItem = "",
	revistar = "",
	pickupItem = ""
}
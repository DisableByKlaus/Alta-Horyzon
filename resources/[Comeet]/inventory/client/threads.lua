Citizen.CreateThread(function()
	while true do
		local idle = 1000
		for k,v in pairs(config.chests.list) do
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(v.x,v.y,v.z)
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.x,v.y,v.z, true )
			if distance < config.chests.config.blipDist then
				idle = 1
				if config.chests.config.enableCustom then
					if not HasStreamedTextureDictLoaded("invblips") then
						RequestStreamedTextureDict("invblips", true)
						while not HasStreamedTextureDictLoaded("invblips") do
							Wait(1)
						end	
					end
					DrawMarker(9, v.x, v.y, cdz+0.7, 0.0, 0.0, 0.0, config.chests.config.rotate[1], config.chests.config.rotate[2], config.chests.config.rotate[3], config.chests.config.size[1], config.chests.config.size[2], config.chests.config.size[3], 255, 255, 255, 255,false, true, 2, false, "invblips", config.chests.config.image, false)
				else
					config.chests.config.notCustom(v.x, v.y, cdz, k, distance)
				end
			end
		end
		Citizen.Wait(idle)
	end
end)

Citizen.CreateThread(function()
	while true do
		local idle = 1000
		local ped = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(ped))
		for a,b in pairs(config.shops.list) do
			for k,v in pairs(b.coords) do
				local x2,y2,z2 = table.unpack(v)
				local bowz,cdz = GetGroundZFor_3dCoord(x2,y2,z2)
				local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), x2,y2,z2, true )
				if distance < config.shops.config.blipDist then
					idle = 1
					if config.shops.config.enableCustom then
						if not HasStreamedTextureDictLoaded("shopblips") then
							RequestStreamedTextureDict("shopblips", true)
							while not HasStreamedTextureDictLoaded("shopblips") do
								Wait(1)
							end	
						end
						DrawMarker(9, x2, y2, cdz+0.7, 0.0, 0.0, 0.0, config.shops.config.rotate[1], config.shops.config.rotate[2], config.shops.config.rotate[3], config.shops.config.size[1], config.shops.config.size[2], config.shops.config.size[3], 255, 255, 255, 255,false, true, 2, false, "invblips", config.shops.config.image, false)
					else
						config.shops.config.notCustom(x2, y2, cdz, a, distance)
					end
				end
			end
		end
		Citizen.Wait(idle)
	end
end)

Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		if weaponActive and Weapon ~= "" then
			timeDistance = 100
			local ped = PlayerPedId()
			local weaponAmmo = GetAmmoInPedWeapon(ped,Weapon)

			if GetGameTimer() >= timeReload and IsPedReloading(ped) then
				src.preventWeapon(Weapon,weaponAmmo)
				timeReload = GetGameTimer() + 1000
			end

			if weaponAmmo <= 0 or (Weapon == "WEAPON_PETROLCAN" and weaponAmmo <= 135 and IsPedShooting(ped)) or IsPedSwimming(ped) then
				src.preventWeapon(Weapon,weaponAmmo)
				RemoveAllPedWeapons(ped,true)
				weaponActive = false
				Weapon = ""
			end
		end

		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do
		local timings = 1000
		local ped = PlayerPedId()
		if IsPedArmed(ped, 4 | 2) then timings = 1 end
		if IsPedShooting(ped) and weaponActive and Weapon ~= "" then
			src.updateAmmo(Weapon, GetAmmoInPedWeapon(ped, GetHashKey(Weapon)))
		end
		Citizen.Wait(timings)
	end
end)

CreateThread(function()
	Drops = src.GetDrops() 
    while true do 
        DisableControlAction(0, 37, true)
        Citizen.Wait(1)
    end
end)

CreateThread(function()
    while true do 
        local sleep = 1500 
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        for k,v in pairs(Drops) do 
            local dist = #(coords-v.coords)
            if dist <= 12 then 
                sleep = 3
				local retval, groundZ  = GetGroundZFor_3dCoord(v.coords.x, v.coords.y, v.coords.z, true)
				
                DrawMarker(2, v.coords.x, v.coords.y, v.coords.z-0.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 255,255, 255, 155, true, true, true, 0, false, false, false)
				DrawMarker(25, v.coords.x, v.coords.y, groundZ+0.01, 0, 0, 0, 0, 0, 0, 0.2, 0.2, 0.1, 255, 255, 255, 180, 0, 0, 2, 1, 0, 0, 0) -- baixo
                if IsControlJustReleased(0,38) and dist <= 1 then 
					TriggerServerEvent('alta-inv:RemoveDrop',k)
                    RequestAnimDict("pickup_object")
                    while not HasAnimDictLoaded("pickup_object") do
                        Citizen.Wait(1)
                    end
                    TaskPlayAnim(GetPlayerPed(-1), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
                    Citizen.Wait(1100)
                    ClearPedTasks(GetPlayerPed(-1))
                    
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)
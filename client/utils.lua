function ClosetVehWithDisplay()
    local veh = GetClosestVehicle(GetEntityCoords(GetPlayerPed(-1)), nil)
    local vCoords = GetEntityCoords(veh)
    DrawMarker(2, vCoords.x, vCoords.y, vCoords.z + 1.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 170, 0, 1, 2, 0, nil, nil, 0)
end

function getCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
    local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

    if len ~= 0 then
        coords = coords / len
    end

    return coords
end

Citizen.CreateThread(function()
	while true do
		Wait(1)
		if blipsActive then
			for _, player in pairs(GetActivePlayers()) do
				local found = false
				if player ~= PlayerId() then
					local ped = GetPlayerPed(player)
					local blip = GetBlipFromEntity( ped )
					if not DoesBlipExist( blip ) then
						blip = AddBlipForEntity(ped)
						SetBlipCategory(blip, 7)
						SetBlipScale( blip,  0.85 )
						ShowHeadingIndicatorOnBlip(blip, true)
						SetBlipSprite(blip, 1)
						SetBlipColour(blip, 0)
					end

					SetBlipNameToPlayerName(blip, player)

					local veh = GetVehiclePedIsIn(ped, false)
					local blipSprite = GetBlipSprite(blip)

					if IsEntityDead(ped) then
						if blipSprite ~= 303 then
							SetBlipSprite( blip, 303 )
							SetBlipColour(blip, 1)
							ShowHeadingIndicatorOnBlip( blip, false )
						end
					elseif veh ~= nil then
						if IsPedInAnyBoat( ped ) then
							if blipSprite ~= 427 then
								SetBlipSprite( blip, 427 )
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip( blip, false )
							end
						elseif IsPedInAnyHeli( ped ) then
							if blipSprite ~= 43 then
								SetBlipSprite( blip, 43 )
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip( blip, false )
							end
						elseif IsPedInAnyPlane( ped ) then
							if blipSprite ~= 423 then
								SetBlipSprite( blip, 423 )
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip( blip, false )
							end
						elseif IsPedInAnyPoliceVehicle( ped ) then
							if blipSprite ~= 137 then
								SetBlipSprite( blip, 137 )
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip( blip, false )
							end
						elseif IsPedInAnySub( ped ) then
							if blipSprite ~= 308 then
								SetBlipSprite( blip, 308 )
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip( blip, false )
							end
						elseif IsPedInAnyVehicle( ped ) then
							if blipSprite ~= 225 then
								SetBlipSprite( blip, 225 )
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip( blip, false )
							end
						else
							if blipSprite ~= 1 then
								SetBlipSprite(blip, 1)
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip( blip, true )
							end
						end
					else
						if blipSprite ~= 1 then
							SetBlipSprite( blip, 1 )
							SetBlipColour(blip, 0)
							ShowHeadingIndicatorOnBlip( blip, true )
						end
					end
					if veh then
						SetBlipRotation( blip, math.ceil( GetEntityHeading( veh ) ) )
					else
						SetBlipRotation( blip, math.ceil( GetEntityHeading( ped ) ) )
					end
				end
			end
		else
			for _, player in pairs(GetActivePlayers()) do
				local blip = GetBlipFromEntity( GetPlayerPed(player) )
				if blip ~= nil then
					RemoveBlip(blip)
				end
			end
		end
	end
end)

entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end

        enum.destructor = nil
        enum.handle = nil
    end
}

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end

        local enum = { handle = iter, destructor = disposeFunc }
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function GetVehicles()
    local vehicles = {}

    for vehicle in EnumerateVehicles() do
        table.insert(vehicles, vehicle)
    end

    return vehicles
end

function GetClosestVehicle(coords)
    local vehicles = GetVehicles()
    local closestDistance = -1
    local closestVehicle = -1
    local coords = coords

    if coords == nil then
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end

    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end

    return closestVehicle, closestDistance
end

function closest()
    local players = GetActivePlayers()
    local coords = GetEntityCoords(pPed)
    local pCloset = nil
    local pClosetPos = nil
    local pClosetDst = nil
    for k, v in pairs(players) do
        if GetPlayerPed(v) ~= pPed then
            local oPed = GetPlayerPed(v)
            local oCoords = GetEntityCoords(oPed)
            local dst = GetDistanceBetweenCoords(oCoords, coords, true)
            if pCloset == nil then
                pCloset = v
                pClosetPos = oCoords
                pClosetDst = dst
            else
                if dst < pClosetDst then
                    pCloset = v
                    pClosetPos = oCoords
                    pClosetDst = dst
                end
            end
        end
    end

    return pCloset, pClosetDst
end

local mpDebugMode = false
RegisterCommand("adminDebug", function()
    mpDebugMode = not mpDebugMode
    if mpDebugMode then
        ESX.ShowNotification("Debug activé")
    else
        ESX.ShowNotification("Debug désactivé")
    end
end)



local gamerTags = {}
function showNames(bool)
    isNameShown = bool
    if isNameShown then
        Citizen.CreateThread(function()
            while isNameShown do
                local plyPed = PlayerPedId()
                for _, player in pairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if ped ~= plyPed then
                        if #(GetEntityCoords(plyPed, false) - GetEntityCoords(ped, false)) < 5000.0 then
                            gamerTags[player] = CreateFakeMpGamerTag(ped, ('[%s] %s'):format(GetPlayerServerId(player), GetPlayerName(player)), false, false, '', 0)
                            SetMpGamerTagAlpha(gamerTags[player], 0, 255)
                            SetMpGamerTagAlpha(gamerTags[player], 2, 255)
                            SetMpGamerTagAlpha(gamerTags[player], 4, 255)
                            SetMpGamerTagAlpha(gamerTags[player], 7, 255)
                            SetMpGamerTagVisibility(gamerTags[player], 0, true)
                            SetMpGamerTagVisibility(gamerTags[player], 2, true)
                            SetMpGamerTagVisibility(gamerTags[player], 4, NetworkIsPlayerTalking(player))
                            SetMpGamerTagVisibility(gamerTags[player], 7, DecorExistOn(ped, "staffl") and DecorGetInt(ped, "staffl") > 0)
                            SetMpGamerTagColour(gamerTags[player], 7, 55)
                            if NetworkIsPlayerTalking(player) then
                                SetMpGamerTagHealthBarColour(gamerTags[player], 211)
                                SetMpGamerTagColour(gamerTags[player], 4, 211)
                                SetMpGamerTagColour(gamerTags[player], 0, 211)
                            else
                                SetMpGamerTagHealthBarColour(gamerTags[player], 0)
                                SetMpGamerTagColour(gamerTags[player], 4, 0)
                                SetMpGamerTagColour(gamerTags[player], 0, 0)
                            end
                            if DecorExistOn(ped, "staffl") then
                                SetMpGamerTagWantedLevel(ped, DecorGetInt(ped, "staffl"))
                            end
                            if mpDebugMode then
                                print(json.encode(DecorExistOn(ped, "staffl")).." - "..json.encode(DecorGetInt(ped, "staffl")))
                            end
                        else
                            RemoveMpGamerTag(gamerTags[player])
                            gamerTags[player] = nil
                        end
                    end
                end
                --[[
                for k, v in ipairs(ESX.Game.GetPlayers()) do
                    local otherPed = GetPlayerPed(v)
                    if otherPed ~= plyPed then
                        if #(GetEntityCoords(plyPed, false) - GetEntityCoords(otherPed, false)) < 5000.0 then
                            gamerTags[v] = CreateFakeMpGamerTag(otherPed, ('[%s] %s'):format(GetPlayerServerId(v), GetPlayerName(v)), false, false, '', 0)
                            SetMpGamerTagAlpha(gamerTags[v], 0, 255)
                            SetMpGamerTagAlpha(gamerTags[v], 2, 255)
                            SetMpGamerTagAlpha(gamerTags[v], 4, 255)
                            SetMpGamerTagVisibility(gamerTags[v], 0, true)
                            SetMpGamerTagVisibility(gamerTags[v], 2, true)
                            SetMpGamerTagVisibility(gamerTags[v], 4, NetworkIsPlayerTalking(otherPed))
                            if NetworkIsPlayerTalking(otherPed) then
                                SetMpGamerTagHealthBarColour(gamerTags[v], 211)
                                SetMpGamerTagColour(gamerTags[v], 4, 211)
                                SetMpGamerTagColour(gamerTags[v], 0, 211)
                            else
                                SetMpGamerTagHealthBarColour(gamerTags[v], 0)
                                SetMpGamerTagColour(gamerTags[v], 4, 0)
                                SetMpGamerTagColour(gamerTags[v], 0, 0)
                            end
                        else
                            RemoveMpGamerTag(gamerTags[v])
                            gamerTags[v] = nil
                        end
                    end
                end
                --]]
                Citizen.Wait(100)
            end
            for k,v in pairs(gamerTags) do
                RemoveMpGamerTag(v)
            end
            gamerTags = {}
        end)
    end
end

function NoClip(bool)
    if permLevel == "user" then
        return
    end
    if not isStaffMode then
        ESX.ShowNotification("~r~[Staff] ~s~Vous devez avoir le staff mode activé pour faire cela !")
        return
    end
    isNoClip = bool
    if isNoClip then
        SetEntityInvincible(PlayerPedId(), true)
        Citizen.CreateThread(function()
            while isNoClip do
                Wait(1)
                local pCoords = GetEntityCoords(PlayerPedId(), false)
                local camCoords = getCamDirection()
                SetEntityVelocity(PlayerPedId(), 0.01, 0.01, 0.01)
                SetEntityCollision(PlayerPedId(), 0, 1)
                FreezeEntityPosition(PlayerPedId(), true)

                if IsControlPressed(0, 32) then
                    pCoords = pCoords + (NoClipSpeed * camCoords)
                end

                if IsControlPressed(0, 269) then
                    pCoords = pCoords - (NoClipSpeed * camCoords)
                end

                if IsDisabledControlJustPressed(1, 15) then
                    NoClipSpeed = NoClipSpeed + 0.3
                end
                if IsDisabledControlJustPressed(1, 14) then
                    NoClipSpeed = NoClipSpeed - 0.3
                    if NoClipSpeed < 0 then
                        NoClipSpeed = 0
                    end
                end
                SetEntityCoordsNoOffset(PlayerPedId(), pCoords, true, true, true)
                SetEntityVisible(PlayerPedId(), 0, 0)

            end
            FreezeEntityPosition(PlayerPedId(), false)
            SetEntityVisible(PlayerPedId(), 1, 0)
            SetEntityCollision(PlayerPedId(), 1, 1)
        end)
    else
        SetEntityInvincible(PlayerPedId(), false)
    end
end

function CustomString()
    local txt = nil
    AddTextEntry("CREATOR_TXT", "Entrez votre texte.")
    DisplayOnscreenKeyboard(1, "CREATOR_TXT", '', "", '', '', '', 15)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        txt = GetOnscreenKeyboardResult()
        Citizen.Wait(1)
    else
        Citizen.Wait(1)
    end
    return txt
end

function input(TextEntry, ExampleText, MaxStringLenght, isValueInt)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        if isValueInt then
            local isNumber = tonumber(result)
            if isNumber then
                return result
            else
                return nil
            end
        end

        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

local function msg(string)
    ESX.ShowNotification(prefix .. string)
end